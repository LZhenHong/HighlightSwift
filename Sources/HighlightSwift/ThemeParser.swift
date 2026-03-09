import Foundation
#if canImport(AppKit)
import AppKit

public typealias PlatformColor = NSColor
#elseif canImport(UIKit)
import UIKit

public typealias PlatformColor = UIColor
#endif

/// Style properties for a single highlight token.
public struct TokenStyle {
  public var color: PlatformColor?
  public var opacity: CGFloat = 1.0
  public var bold: Bool = false
  public var italic: Bool = false

  /// Returns the effective color with opacity applied.
  public var effectiveColor: PlatformColor? {
    guard let color else { return nil }
    guard opacity < 1.0 else { return color }
    return color.withAlphaComponent(opacity)
  }
}

/// Parses highlight.js CSS theme files into token style dictionaries.
enum ThemeParser {
  /// Parse a theme into token styles keyed by class name.
  /// Special keys: `_default` (base text), `_background` (background color).
  static func parseStyles(theme: HighlightTheme) throws -> [String: TokenStyle] {
    let css = try loadCSS(for: theme)
    let resolvedCSS = CSSVariableResolver.resolve(in: css)
    return parseCSS(resolvedCSS)
  }

  /// Backward-compatible color parsing entry point used by tests.
  static func parseColor(_ string: String) -> PlatformColor? {
    ColorParser.parse(string)
  }

  // MARK: - CSS Loading

  private static func loadCSS(for theme: HighlightTheme) throws -> String {
    let name = theme.rawValue
    let cssURL: URL?
    if name.contains("/") {
      let parts = name.split(separator: "/", maxSplits: 1)
      cssURL = Bundle.module.url(
        forResource: String(parts[1]),
        withExtension: "css",
        subdirectory: "Resources/styles/\(parts[0])"
      )
    } else {
      cssURL = Bundle.module.url(forResource: name, withExtension: "css", subdirectory: "Resources/styles")
    }

    guard let url = cssURL, let css = try? String(contentsOf: url, encoding: .utf8) else {
      throw HighlightError.themeNotFound
    }
    return css
  }

  // MARK: - Cached Regex Patterns

  private static let blockRegex = try! NSRegularExpression(
    pattern: #"([^{}]+)\{([^}]+)\}"#,
    options: .dotMatchesLineSeparators
  )

  private static let colorRegex = try! NSRegularExpression(
    pattern: #"(?<![a-z-])color\s*:\s*(#[0-9a-fA-F]{3,8}|rgb[a]?\([^)]+\)|[a-zA-Z]+)"#
  )

  private static let opacityRegex = try! NSRegularExpression(
    pattern: #"opacity\s*:\s*([0-9]*\.?[0-9]+)"#
  )

  private static let baseRegex = try! NSRegularExpression(
    pattern: #"\.hljs\s*\{([^}]+)\}"#
  )

  private static let bgRegex = try! NSRegularExpression(
    pattern: #"background(?:-color)?\s*:\s*(#[0-9a-fA-F]{3,8}|rgb[a]?\([^)]+\)|[a-zA-Z]+)"#
  )

  // MARK: - CSS Parsing

  private static func parseCSS(_ css: String) -> [String: TokenStyle] {
    var styles: [String: TokenStyle] = [:]
    let blocks = blockRegex.matches(in: css, range: NSRange(css.startIndex..., in: css))

    for block in blocks {
      guard let selectorsRange = Range(block.range(at: 1), in: css),
            let propsRange = Range(block.range(at: 2), in: css) else { continue }

      let selectors = String(css[selectorsRange])
      let props = String(css[propsRange])
      let style = parseBlockStyle(from: props)

      applyStyle(style, selectors: selectors, into: &styles)
    }

    parseBaseStyles(css: css, into: &styles)
    return styles
  }

  /// Extract a TokenStyle from a CSS property block.
  private static func parseBlockStyle(from props: String) -> TokenStyle {
    var style = TokenStyle()

    if let colorString = extractFirstMatch(colorRegex, in: props) {
      style.color = ColorParser.parse(colorString)
    }

    if let opString = extractFirstMatch(opacityRegex, in: props),
       let opVal = Double(opString) {
      style.opacity = CGFloat(opVal)
    }

    if props.contains("font-weight"), props.contains("bold") {
      style.bold = true
    }

    if props.contains("font-style"), props.contains("italic") {
      style.italic = true
    }

    return style
  }

  /// Apply a parsed style to all selector keys, merging with existing styles.
  private static func applyStyle(
    _ style: TokenStyle,
    selectors: String,
    into styles: inout [String: TokenStyle]
  ) {
    let hasColor = style.color != nil
    let selectorParts = selectors.split(separator: ",").map {
      $0.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    for sel in selectorParts {
      for key in extractKeys(from: sel) {
        if var existing = styles[key] {
          if style.color != nil { existing.color = style.color }
          if style.opacity < 1.0 { existing.opacity = style.opacity }
          if style.bold { existing.bold = true }
          if style.italic { existing.italic = true }
          styles[key] = existing
        } else if hasColor || style.bold || style.italic {
          styles[key] = style
        }
      }
    }
  }

  /// Parse .hljs base block for default text color and background.
  private static func parseBaseStyles(css: String, into styles: inout [String: TokenStyle]) {
    let baseMatches = baseRegex.matches(in: css, range: NSRange(css.startIndex..., in: css))
    for baseMatch in baseMatches {
      guard let basePropsRange = Range(baseMatch.range(at: 1), in: css) else { continue }
      let baseProps = String(css[basePropsRange])

      if styles["_default"] == nil,
         let colorString = extractFirstMatch(colorRegex, in: baseProps),
         let color = ColorParser.parse(colorString) {
        styles["_default"] = TokenStyle(color: color)
      }

      if styles["_background"] == nil,
         let bgString = extractFirstMatch(bgRegex, in: baseProps),
         let bgColor = ColorParser.parse(bgString) {
        styles["_background"] = TokenStyle(color: bgColor)
      }
    }
  }

  // MARK: - Regex Helpers

  private static func extractFirstMatch(_ regex: NSRegularExpression, in text: String) -> String? {
    guard let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
          let range = Range(match.range(at: 1), in: text) else { return nil }
    return String(text[range]).trimmingCharacters(in: .whitespaces)
  }

  // MARK: - Selector Parsing

  /// Extract style keys from a single CSS selector.
  ///
  /// Examples:
  /// - `.hljs-keyword` → `["keyword"]`
  /// - `.hljs-title.function_` → `["title.function_"]`
  /// - `.hljs-class .hljs-title` → `["class>title"]` (descendant only)
  /// - `.diff .hljs-meta` → `["meta"]` (non-hljs parent ignored)
  private static func extractKeys(from selector: String) -> [String] {
    let normalized = selector.replacingOccurrences(of: ">", with: " ")
    let parts = normalized.split(separator: " ")
      .map { String($0).trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }

    let hljsParts: [(token: String, hasHljs: Bool)] = parts.map { part in
      if let token = extractTokenFromPart(part) {
        (token: token, hasHljs: true)
      } else {
        (token: part, hasHljs: false)
      }
    }

    let hljsTokens = hljsParts.filter(\.hasHljs)

    switch hljsTokens.count {
    case 0:
      return []
    case 1:
      return [hljsTokens[0].token]
    default:
      // Descendant selector: only add the composite key, not individual tokens
      return [hljsTokens.map(\.token).joined(separator: ">")]
    }
  }

  /// Extract a normalized token name from a CSS selector part.
  /// `.hljs-keyword` → `"keyword"`
  /// `.hljs-title.function_` → `"title.function_"`
  /// `.ruby` → `nil`
  private static func extractTokenFromPart(_ part: String) -> String? {
    let classes = part.split(separator: ".", omittingEmptySubsequences: true).map(String.init)

    var primaryName: String?
    var modifiers: [String] = []

    for cls in classes {
      if cls.hasPrefix("hljs-") {
        let name = String(cls.dropFirst(5))
        if primaryName == nil {
          primaryName = name
        } else {
          modifiers.append(name)
        }
      } else if primaryName != nil {
        modifiers.append(cls)
      }
    }

    guard let primary = primaryName else { return nil }
    return modifiers.isEmpty ? primary : primary + "." + modifiers.joined(separator: ".")
  }
}

// MARK: - CSS Variable Resolution

private enum CSSVariableResolver {
  private static let rootBlockRegex = try! NSRegularExpression(
    pattern: #"(?::root|:host)\s*(?:,\s*(?::root|:host)\s*)*\{([^}]+)\}"#,
    options: .dotMatchesLineSeparators
  )

  private static let varDefRegex = try! NSRegularExpression(
    pattern: #"(--[a-zA-Z0-9-]+)\s*:\s*([^;}\n]+)"#
  )

  private static let varRefRegex = try! NSRegularExpression(
    pattern: #"var\(\s*(--[a-zA-Z0-9-]+)\s*\)"#
  )

  static func resolve(in css: String) -> String {
    let variables = extractVariables(from: css)
    guard !variables.isEmpty else { return css }
    return substituteVariables(variables, in: css)
  }

  private static func extractVariables(from css: String) -> [String: String] {
    var variables: [String: String] = [:]
    let rootMatches = rootBlockRegex.matches(in: css, range: NSRange(css.startIndex..., in: css))
    for rootMatch in rootMatches {
      guard let propsRange = Range(rootMatch.range(at: 1), in: css) else { continue }
      let props = String(css[propsRange])
      let defMatches = varDefRegex.matches(in: props, range: NSRange(props.startIndex..., in: props))
      for defMatch in defMatches {
        guard let nameRange = Range(defMatch.range(at: 1), in: props),
              let valueRange = Range(defMatch.range(at: 2), in: props) else { continue }
        variables[String(props[nameRange])] = String(props[valueRange]).trimmingCharacters(in: .whitespaces)
      }
    }
    return variables
  }

  private static func substituteVariables(_ variables: [String: String], in css: String) -> String {
    var resolved = css
    // Iterate up to 3 times for nested var() references
    for _ in 0..<3 {
      let matches = varRefRegex.matches(in: resolved, range: NSRange(resolved.startIndex..., in: resolved))
      guard !matches.isEmpty else { break }
      for match in matches.reversed() {
        guard let fullRange = Range(match.range, in: resolved),
              let nameRange = Range(match.range(at: 1), in: resolved) else { continue }
        if let value = variables[String(resolved[nameRange])] {
          resolved.replaceSubrange(fullRange, with: value)
        }
      }
    }
    return resolved
  }
}
