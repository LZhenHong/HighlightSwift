import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

enum AttributedStringBuilder {
  /// Build from HTML + full token styles (with bold/italic/opacity support).
  static func build(from html: String, styles: [String: TokenStyle]) -> NSAttributedString {
    let result = NSMutableAttributedString()
    let defaultStyle = styles["_default"]
    parse(html: html[...], styles: styles, inheritedStyle: defaultStyle, parentTokens: [], into: result)
    return result
  }

  private static func parse(
    html: Substring,
    styles: [String: TokenStyle],
    inheritedStyle: TokenStyle?,
    parentTokens: [String],
    into result: NSMutableAttributedString
  ) {
    var scanner = html

    while !scanner.isEmpty {
      if scanner.hasPrefix("<span class=\"") {
        guard let closeTag = scanner.range(of: "\">") else {
          appendText(decodeHTMLEntities(String(scanner)), style: inheritedStyle, to: result)
          break
        }
        let classStart = scanner.index(scanner.startIndex, offsetBy: 13)
        let classValue = String(scanner[classStart..<closeTag.lowerBound])
        scanner = scanner[closeTag.upperBound...]

        // Resolve style from class names
        let (resolvedStyle, tokenName) = resolveStyle(classValue: classValue, styles: styles, parentTokens: parentTokens, fallback: inheritedStyle)

        // Find matching </span> accounting for nesting
        let (innerHtml, rest) = extractSpanContent(scanner)
        scanner = rest

        // Build new parent chain for descendant selector matching
        var newParents = parentTokens
        if let tn = tokenName {
          newParents.append(tn)
        }

        parse(html: innerHtml, styles: styles, inheritedStyle: resolvedStyle, parentTokens: newParents, into: result)

      } else if scanner.hasPrefix("</span>") {
        scanner = scanner[scanner.index(scanner.startIndex, offsetBy: 7)...]
      } else if scanner.hasPrefix("<") {
        if let close = scanner.range(of: ">") {
          scanner = scanner[close.upperBound...]
        } else {
          break
        }
      } else {
        if let nextTag = scanner.range(of: "<") {
          let text = String(scanner[..<nextTag.lowerBound])
          appendText(decodeHTMLEntities(text), style: inheritedStyle, to: result)
          scanner = scanner[nextTag.lowerBound...]
        } else {
          appendText(decodeHTMLEntities(String(scanner)), style: inheritedStyle, to: result)
          break
        }
      }
    }
  }

  /// Resolve style for a class value, trying compound and descendant selectors.
  /// Returns (resolved style, primary token name for parent tracking).
  private static func resolveStyle(
    classValue: String,
    styles: [String: TokenStyle],
    parentTokens: [String],
    fallback: TokenStyle?
  ) -> (TokenStyle?, String?) {
    // Class value can be "hljs-keyword" or "hljs-title function_"
    let parts = classValue.split(separator: " ")

    // Extract the primary hljs token name (e.g. "keyword", "title")
    var primaryName: String?
    var secondaryParts: [String] = []

    for part in parts {
      let name = part.hasPrefix("hljs-") ? String(part.dropFirst(5)) : String(part)
      if primaryName == nil, part.hasPrefix("hljs-") {
        primaryName = name
      } else {
        secondaryParts.append(name)
      }
    }

    guard let tokenName = primaryName else {
      return (fallback, nil)
    }

    // Try compound selector first (most specific): "title.function_"
    if !secondaryParts.isEmpty {
      let compoundKey = tokenName + "." + secondaryParts.joined(separator: ".")
      if let style = styles[compoundKey] {
        return (mergeStyle(style, into: fallback), tokenName)
      }
    }

    // Try descendant selector: "parent>tokenName"
    for parent in parentTokens.reversed() {
      let descendantKey = parent + ">" + tokenName
      if let style = styles[descendantKey] {
        return (mergeStyle(style, into: fallback), tokenName)
      }
    }

    // Try direct token name
    if let style = styles[tokenName] {
      return (mergeStyle(style, into: fallback), tokenName)
    }

    return (fallback, tokenName)
  }

  /// Merge a specific style on top of a fallback.
  private static func mergeStyle(_ style: TokenStyle, into fallback: TokenStyle?) -> TokenStyle {
    var merged = style
    if merged.color == nil, let fb = fallback {
      merged.color = fb.color
    }
    return merged
  }

  /// Extract content inside a span, handling nesting.
  private static func extractSpanContent(_ html: Substring) -> (Substring, Substring) {
    var depth = 1
    var idx = html.startIndex

    while idx < html.endIndex {
      let remaining = html[idx...]

      if remaining.hasPrefix("</span>") {
        depth -= 1
        if depth == 0 {
          let inner = html[html.startIndex..<idx]
          let after = html[html.index(idx, offsetBy: 7)...]
          return (inner, after)
        }
        idx = html.index(idx, offsetBy: 7)
      } else if remaining.hasPrefix("<span") {
        depth += 1
        if let closeTag = remaining.range(of: ">") {
          idx = closeTag.upperBound
        } else {
          idx = html.index(after: idx)
        }
      } else {
        idx = html.index(after: idx)
      }
    }

    return (html, html[html.endIndex...])
  }

  private static func appendText(_ text: String, style: TokenStyle?, to result: NSMutableAttributedString) {
    guard !text.isEmpty else { return }
    var attrs: [NSAttributedString.Key: Any] = [:]
    if let style {
      if let color = style.effectiveColor {
        attrs[.foregroundColor] = color
      }
    }
    // Always set a monospaced font so attributed strings render correctly
    // in NSTextView / UITextView without relying on the view's default font.
    let isBold = style?.bold ?? false
    let isItalic = style?.italic ?? false
    #if canImport(UIKit)
    let baseFont = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: isBold ? .bold : .regular)
    if isItalic || isBold {
      var traits: UIFontDescriptor.SymbolicTraits = []
      if isBold { traits.insert(.traitBold) }
      if isItalic { traits.insert(.traitItalic) }
      if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits) {
        attrs[.font] = UIFont(descriptor: descriptor, size: baseFont.pointSize)
      } else {
        attrs[.font] = baseFont
      }
    } else {
      attrs[.font] = baseFont
    }
    #elseif canImport(AppKit)
    var font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: isBold ? .bold : .regular)
    if isItalic {
      let descriptor = font.fontDescriptor.withSymbolicTraits(.italic)
      font = NSFont(descriptor: descriptor, size: font.pointSize) ?? font
    }
    attrs[.font] = font
    #endif
    result.append(NSAttributedString(string: text, attributes: attrs))
  }

  private static func decodeHTMLEntities(_ string: String) -> String {
    string
      .replacingOccurrences(of: "&amp;", with: "&")
      .replacingOccurrences(of: "&lt;", with: "<")
      .replacingOccurrences(of: "&gt;", with: ">")
      .replacingOccurrences(of: "&quot;", with: "\"")
      .replacingOccurrences(of: "&#x27;", with: "'")
      .replacingOccurrences(of: "&#39;", with: "'")
  }
}
