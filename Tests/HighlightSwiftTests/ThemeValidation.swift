import Foundation
@testable import HighlightSwift
import Testing

/// Comprehensive theme validation — checks all themes for CSS parsing correctness.
@Suite(.serialized)
struct ThemeValidation {
  // MARK: - Validate ALL themes parse without crashes and produce usable output

  @Test
  func validateAllThemesProduceColors() throws {
    // Themes known to lack _default/_background (minimal or unusual CSS structure)
    let knownExceptions: Set = [
      "felipec", // Uses only class-specific colors, no .hljs base block
    ]

    let themes = HighlightTheme.allThemes()
    var parseErrors: [(theme: String, error: String)] = []
    var emptyThemes: [String] = []
    var missingBaseThemes: [String] = []

    for theme in themes {
      do {
        let styles = try ThemeParser.parseStyles(theme: theme)
        if styles.isEmpty {
          emptyThemes.append(theme.rawValue)
        }
        if styles["_default"] == nil, styles["_background"] == nil {
          if !knownExceptions.contains(theme.rawValue) {
            missingBaseThemes.append(theme.rawValue)
          }
        }
      } catch {
        parseErrors.append((theme.rawValue, "\(error)"))
      }
    }

    if !parseErrors.isEmpty || !emptyThemes.isEmpty || !missingBaseThemes.isEmpty {
      print("=== THEME ISSUES ===")
      for (theme, err) in parseErrors {
        print("  PARSE ERROR: \(theme): \(err)")
      }
      for theme in emptyThemes {
        print("  EMPTY: \(theme)")
      }
      for theme in missingBaseThemes {
        print("  MISSING BASE: \(theme)")
      }
      print("====================")
    }

    #expect(parseErrors.isEmpty, "No themes should fail to parse: \(parseErrors.map(\.theme))")
    #expect(emptyThemes.isEmpty, "No themes should produce empty styles: \(emptyThemes)")
    #expect(missingBaseThemes.isEmpty, "Themes missing _default and _background (add to knownExceptions if intentional): \(missingBaseThemes)")
  }

  // MARK: - Validate descendant selectors don't pollute direct keys

  @Test
  func validateDescendantSelectorIsolation() throws {
    // All base16 themes use the same CSS structure with descendant selectors like:
    //   .hljs-meta .hljs-keyword { color: X }
    // This should NOT override the standalone .hljs-keyword color.
    //
    // The base16 CSS template always has:
    //   base0E (.hljs-keyword) and base0F (.hljs-meta .hljs-keyword)
    // If they're the same color, the test is inconclusive.
    // If different, keyword must match base0E, not base0F.

    let base16Themes = HighlightTheme.allThemes().filter { $0.rawValue.hasPrefix("base16/") }
    var failures: [(theme: String, detail: String)] = []

    for theme in base16Themes {
      guard let cssURL = Bundle.module.url(
        forResource: String(theme.rawValue.split(separator: "/")[1]),
        withExtension: "css",
        subdirectory: "Resources/styles/base16"
      ) else { continue }

      let css = try String(contentsOf: cssURL, encoding: .utf8)

      // Extract base0E color (the one assigned to .hljs-keyword standalone)
      // and base0F color (assigned to .hljs-meta .hljs-keyword)
      let base0E = extractBaseColor(css, label: "base0E")
      let base0F = extractBaseColor(css, label: "base0F")

      guard let e = base0E, let f = base0F, e.lowercased() != f.lowercased() else {
        continue // Same color or not found — inconclusive
      }

      // Parse and check
      let styles = try ThemeParser.parseStyles(theme: theme)
      guard let keywordStyle = styles["keyword"],
            let keywordColor = keywordStyle.color else {
        failures.append((theme.rawValue, "no keyword color found"))
        continue
      }

      let keywordHex = colorToHex(keywordColor)
      if keywordHex.lowercased() != e.lowercased() {
        failures.append((
          theme.rawValue,
          "keyword is \(keywordHex), expected base0E \(e) (base0F is \(f))"
        ))
      }
    }

    if !failures.isEmpty {
      print("=== DESCENDANT ISOLATION FAILURES ===")
      for f in failures {
        print("  \(f.theme): \(f.detail)")
      }
      print("=====================================")
    }

    #expect(failures.isEmpty, "\(failures.count) base16 themes have keyword color polluted by descendant selectors")
  }

  // MARK: - Validate popular non-base16 themes

  @Test
  func validateGithubTheme() throws {
    let styles = try ThemeParser.parseStyles(theme: .github)
    // Github theme colors from bundled CSS:
    // .hljs-keyword: #d73a49 (red)
    // .hljs-string: #032f62 (dark blue)
    // .hljs-comment: #6a737d (grey)
    assertColorApprox(styles, key: "keyword", expected: "#d73a49", theme: "github")
    assertColorApprox(styles, key: "string", expected: "#032f62", theme: "github")
    assertColorApprox(styles, key: "comment", expected: "#6a737d", theme: "github")
    #expect(styles["_background"] != nil, "github should have background")
  }

  @Test
  func validateGithubDarkTheme() throws {
    let styles = try ThemeParser.parseStyles(theme: .githubDark)
    assertColorApprox(styles, key: "keyword", expected: "#ff7b72", theme: "github-dark")
    assertColorApprox(styles, key: "string", expected: "#a5d6ff", theme: "github-dark")
    assertColorApprox(styles, key: "comment", expected: "#8b949e", theme: "github-dark")
    #expect(styles["_background"] != nil, "github-dark should have background")
  }

  @Test
  func validateMonokaiSublimeTheme() throws {
    let styles = try ThemeParser.parseStyles(theme: .monokaiSublime)
    // Monokai Sublime:
    // .hljs-keyword: #f92672 (pink/red)
    // .hljs-string: #e6db74 (yellow)
    // .hljs-number: #ae81ff (purple)
    assertColorApprox(styles, key: "keyword", expected: "#f92672", theme: "monokai-sublime")
    assertColorApprox(styles, key: "string", expected: "#e6db74", theme: "monokai-sublime")
    assertColorApprox(styles, key: "number", expected: "#ae81ff", theme: "monokai-sublime")
  }

  @Test
  func validateAtomOneDarkTheme() throws {
    let styles = try ThemeParser.parseStyles(theme: .atomOneDark)
    // Atom One Dark:
    // .hljs-keyword: #c678dd (purple)
    // .hljs-string: #98c379 (green)
    // .hljs-number: #d19a66 (orange)
    assertColorApprox(styles, key: "keyword", expected: "#c678dd", theme: "atom-one-dark")
    assertColorApprox(styles, key: "string", expected: "#98c379", theme: "atom-one-dark")
    assertColorApprox(styles, key: "number", expected: "#d19a66", theme: "atom-one-dark")
  }

  @Test
  func validateNordTheme() throws {
    let styles = try ThemeParser.parseStyles(theme: .nord)
    // Nord:
    // .hljs-keyword: #81A1C1 (blue)
    // .hljs-string: #A3BE8C (green)
    // .hljs-number: #B48EAD (purple)
    assertColorApprox(styles, key: "keyword", expected: "#81A1C1", theme: "nord")
    assertColorApprox(styles, key: "string", expected: "#A3BE8C", theme: "nord")
    assertColorApprox(styles, key: "number", expected: "#B48EAD", theme: "nord")
  }

  @Test
  func validateVs2015Theme() throws {
    let styles = try ThemeParser.parseStyles(theme: .vs2015)
    // VS 2015 Dark:
    // .hljs-keyword: #569CD6 (blue)
    // .hljs-string: #D69D85 (light brown)
    assertColorApprox(styles, key: "keyword", expected: "#569CD6", theme: "vs2015")
    assertColorApprox(styles, key: "string", expected: "#D69D85", theme: "vs2015")
  }

  @Test
  func validateDraculaKeywordColor() throws {
    let styles = try ThemeParser.parseStyles(theme: HighlightTheme("base16/dracula"))
    // base0E = #b45bcf (purple) for keyword
    // base0D = #62d6e8 (cyan) for function title
    // base0A = #00f769 (green) for classes
    assertColorApprox(styles, key: "keyword", expected: "#b45bcf", theme: "dracula")
    assertColorApprox(styles, key: "title.function_", expected: "#62d6e8", theme: "dracula")
    assertColorApprox(styles, key: "title.class_", expected: "#00f769", theme: "dracula")
    assertColorApprox(styles, key: "string", expected: "#ebff87", theme: "dracula")
    assertColorApprox(styles, key: "number", expected: "#b45bcf", theme: "dracula")
    assertColorApprox(styles, key: "comment", expected: "#626483", theme: "dracula")

    // Verify descendant keys exist but don't pollute
    #expect(styles["meta>keyword"] != nil, "dracula should have meta>keyword descendant key")
    #expect(styles["function>title"] != nil, "dracula should have function>title descendant key")
  }

  // MARK: - Validate opacity is applied correctly

  @Test
  func validateOpacityParsing() throws {
    // All base16 themes have .hljs-operator { opacity: 0.7 }
    let themes = ["base16/dracula", "base16/monokai", "base16/nord", "base16/solarized-dark"]
    for themeName in themes {
      let styles = try ThemeParser.parseStyles(theme: HighlightTheme(themeName))
      if let opStyle = styles["operator"] {
        #expect(
          opStyle.opacity < 1.0,
          "\(themeName) operator should have opacity < 1.0, got \(opStyle.opacity)"
        )
      }
    }
  }

  // MARK: - End-to-end: highlight same code with multiple themes and verify output

  @Test
  func validateHighlightOutputAcrossThemes() throws {
    Highlighter.clearCache()
    let code = "func test(_ x: Int) -> String { return \"hello \\(x)\" }"
    let themes: [HighlightTheme] = [
      .github, .githubDark, .monokai, .monokaiSublime,
      .atomOneDark, .atomOneLight, .nord, .vs, .vs2015,
      .xcode, .dark,
      HighlightTheme("base16/dracula"),
      HighlightTheme("base16/solarized-dark"),
      HighlightTheme("base16/nord"),
    ]

    var issues: [String] = []
    for theme in themes {
      do {
        let result = try Highlighter.highlightWithBackground(code, language: "swift", theme: theme)
        let text = result.attributedString.string
        if text.isEmpty {
          issues.append("\(theme.rawValue): empty output")
        }
        if !text.contains("func") || !text.contains("hello") {
          issues.append("\(theme.rawValue): text content missing")
        }
        // Check that we have foreground color attributes applied
        var hasColor = false
        result.attributedString.enumerateAttribute(.foregroundColor, in: NSRange(location: 0, length: result.attributedString.length)) { val, _, _ in
          if val != nil { hasColor = true }
        }
        if !hasColor {
          issues.append("\(theme.rawValue): no foreground colors applied")
        }
      } catch {
        issues.append("\(theme.rawValue): \(error)")
      }
    }

    if !issues.isEmpty {
      print("=== HIGHLIGHT OUTPUT ISSUES ===")
      for issue in issues {
        print("  \(issue)")
      }
      print("===============================")
    }

    #expect(issues.isEmpty, "\(issues.count) themes had output issues")
  }

  // MARK: - Helpers

  private func extractBaseColor(_ css: String, label: String) -> String? {
    // Look for comments like "base0E  #b45bcf" in the CSS header
    let pattern = "\(label)\\s+#([0-9a-fA-F]{6})"
    guard let regex = try? NSRegularExpression(pattern: pattern),
          let match = regex.firstMatch(in: css, range: NSRange(css.startIndex..., in: css)),
          let range = Range(match.range(at: 1), in: css) else {
      return nil
    }
    return "#" + String(css[range])
  }

  private func colorToHex(_ color: PlatformColor) -> String {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
    color.getRed(&r, green: &g, blue: &b, alpha: nil)
    return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
  }

  private func assertColorApprox(
    _ styles: [String: TokenStyle],
    key: String,
    expected: String,
    theme: String
  ) {
    guard let style = styles[key], let color = style.effectiveColor else {
      Issue.record("[\(theme)] missing style for '\(key)'")
      return
    }

    let actual = colorToHex(color)
    let match = actual.lowercased() == expected.lowercased()
    #expect(match, "[\(theme)] \(key): got \(actual), expected \(expected)")
  }
}
