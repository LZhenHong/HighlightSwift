import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public struct HighlightTheme: Hashable, Sendable {
  public let rawValue: String

  public init(_ name: String) {
    rawValue = name
  }

  // Popular light themes
  public static let github = HighlightTheme("github")
  public static let atomOneLight = HighlightTheme("atom-one-light")
  public static let vs = HighlightTheme("vs")
  public static let xcode = HighlightTheme("xcode")
  public static let idea = HighlightTheme("idea")
  public static let intellijLight = HighlightTheme("intellij-light")
  public static let stackoverflowLight = HighlightTheme("stackoverflow-light")
  public static let default_ = HighlightTheme("default")

  // Popular dark themes
  public static let githubDark = HighlightTheme("github-dark")
  public static let githubDarkDimmed = HighlightTheme("github-dark-dimmed")
  public static let monokai = HighlightTheme("monokai")
  public static let monokaiSublime = HighlightTheme("monokai-sublime")
  public static let atomOneDark = HighlightTheme("atom-one-dark")
  public static let vs2015 = HighlightTheme("vs2015")
  public static let nord = HighlightTheme("nord")
  public static let dark = HighlightTheme("dark")
  public static let nightOwl = HighlightTheme("night-owl")
  public static let obsidian = HighlightTheme("obsidian")
  public static let tokyoNightDark = HighlightTheme("tokyo-night-dark")
  public static let rosePine = HighlightTheme("rose-pine")
  public static let shadesOfPurple = HighlightTheme("shades-of-purple")
  public static let sunburst = HighlightTheme("sunburst")

  /// Returns all available theme names by scanning the bundled styles directory.
  public static func allThemes() -> [HighlightTheme] {
    guard let stylesURL = Bundle.module.url(forResource: "styles", withExtension: nil, subdirectory: "Resources") else {
      return []
    }
    var names = Set<String>()

    func scan(directory: URL, prefix: String = "") {
      guard let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return }
      for file in files {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: file.path, isDirectory: &isDir), isDir.boolValue {
          scan(directory: file, prefix: file.lastPathComponent + "/")
        } else if file.pathExtension == "css" {
          let name = file.deletingPathExtension().lastPathComponent
          if !name.hasSuffix(".min") {
            names.insert(prefix + name)
          }
        }
      }
    }

    scan(directory: stylesURL)
    return names.sorted().map { HighlightTheme($0) }
  }
}

public enum HighlightError: Error {
  case engineInitFailed
  case highlightFailed
  case themeNotFound
  case languageNotSupported
}

public struct HighlightResult {
  public let attributedString: NSAttributedString
  public let backgroundColor: PlatformColor?
}

public enum Highlighter {
  private static let cache = HighlightCache.shared

  public static func highlight(
    _ code: String,
    language: String,
    theme: HighlightTheme = .default_
  ) throws -> NSAttributedString {
    let html = try cachedHighlight(code, language: language)
    let styles = try cachedStyles(theme)
    return AttributedStringBuilder.build(from: html, styles: styles)
  }

  public static func highlightWithBackground(
    _ code: String,
    language: String,
    theme: HighlightTheme = .default_
  ) throws -> HighlightResult {
    let html = try cachedHighlight(code, language: language)
    let styles = try cachedStyles(theme)
    let attrStr = AttributedStringBuilder.build(from: html, styles: styles)
    let bg = styles["_background"]?.effectiveColor
    return HighlightResult(attributedString: attrStr, backgroundColor: bg)
  }

  public static func listLanguages() -> [String] {
    (try? HighlightEngine.shared.listLanguages()) ?? []
  }

  /// Clear all internal caches.
  public static func clearCache() {
    cache.clearAll()
  }

  // MARK: - Internal cached helpers

  private static func cachedHighlight(_ code: String, language: String) throws -> String {
    if let cached = cache.cachedHTML(code: code, language: language) {
      return cached
    }
    let html = try HighlightEngine.shared.highlight(code, language: language)
    cache.setHTML(html, code: code, language: language)
    return html
  }

  private static func cachedStyles(_ theme: HighlightTheme) throws -> [String: TokenStyle] {
    if let cached = cache.cachedStyles(theme) {
      return cached
    }
    let styles = try ThemeParser.parseStyles(theme: theme)
    cache.setStyles(styles, for: theme)
    return styles
  }
}
