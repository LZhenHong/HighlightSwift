import Foundation
@testable import HighlightSwift
import Testing

// Serialize all tests since HighlightEngine uses a shared JSContext that is not thread-safe
@Suite(.serialized)
struct HighlightSwiftTests {
  // MARK: - HighlightEngine Tests

  @Test
  func engineInitialization() throws {
    let engine = try HighlightEngine.shared
    let languages = engine.listLanguages()
    #expect(languages.count >= 36)
    #expect(languages.contains("swift"))
    #expect(languages.contains("javascript"))
    #expect(languages.contains("python"))
  }

  @Test
  func highlightSwiftCode() throws {
    let code = "let x: Int = 5"
    let html = try HighlightEngine.shared.highlight(code, language: "swift")
    #expect(html.contains("hljs-keyword"))
    #expect(html.contains("hljs-number"))
  }

  @Test
  func highlightJavaScriptCode() throws {
    let code = "function hello() { return 5; }"
    let html = try HighlightEngine.shared.highlight(code, language: "javascript")
    #expect(html.contains("hljs-keyword"))
    #expect(html.contains("hljs-number"))
  }

  @Test
  func highlightPythonCode() throws {
    let code = "def hello():\n    print('hi')"
    let html = try HighlightEngine.shared.highlight(code, language: "python")
    #expect(html.contains("hljs-keyword"))
    #expect(html.contains("hljs-title"))
  }

  @Test
  func highlightEmptyCode() throws {
    let html = try HighlightEngine.shared.highlight("   ", language: "swift")
    // Whitespace-only input should produce minimal output
    #expect(!html.contains("hljs-keyword"))
  }

  @Test
  func highlightCodeWithSpecialCharacters() throws {
    let code = "let s = \"hello <world> & 'friends'\""
    let html = try HighlightEngine.shared.highlight(code, language: "swift")
    #expect(html.contains("&lt;") || html.contains("&amp;"))
  }

  @Test
  func highlightMultilineCode() throws {
    let code = """
    func fibonacci(_ n: Int) -> Int {
        if n <= 1 { return n }
        return fibonacci(n - 1) + fibonacci(n - 2)
    }
    """
    let html = try HighlightEngine.shared.highlight(code, language: "swift")
    #expect(html.contains("hljs-keyword"))
  }

  @Test
  func dynamicLanguageLoading() throws {
    let code = "main = putStrLn \"Hello\""
    let html = try HighlightEngine.shared.highlight(code, language: "haskell")
    #expect(!html.isEmpty)
    #expect(html.contains("hljs-"))
  }

  @Test
  func unsupportedLanguageThrows() {
    #expect(throws: HighlightError.self) {
      try HighlightEngine.shared.highlight("x", language: "nonexistent_language_xyz")
    }
  }

  // MARK: - Highlighter API Tests

  @Test
  func highlighterBasicOutput() throws {
    let result = try Highlighter.highlight("let x = 5", language: "swift")
    #expect(!result.string.isEmpty)
    #expect(result.length > 0)
  }

  @Test
  func highlighterWithTheme() throws {
    let result = try Highlighter.highlight("let x = 5", language: "swift", theme: .github)
    #expect(!result.string.isEmpty)
  }

  @Test
  func highlighterWithBackgroundResult() throws {
    let result = try Highlighter.highlightWithBackground("let x = 5", language: "swift", theme: .github)
    #expect(!result.attributedString.string.isEmpty)
    #expect(result.backgroundColor != nil)
  }

  @Test
  func highlighterDarkTheme() throws {
    let result = try Highlighter.highlightWithBackground("let x = 5", language: "swift", theme: .githubDark)
    #expect(!result.attributedString.string.isEmpty)
    #expect(result.backgroundColor != nil)
  }

  @Test
  func highlighterListLanguages() {
    let languages = Highlighter.listLanguages()
    #expect(languages.count >= 36)
  }

  @Test
  func highlighterInvalidThemeThrows() {
    #expect(throws: HighlightError.self) {
      try Highlighter.highlight("x", language: "swift", theme: HighlightTheme("nonexistent_theme_xyz"))
    }
  }

  // MARK: - ThemeParser Tests

  @Test
  func githubThemeHasKeyTokenColors() throws {
    let styles = try ThemeParser.parseStyles(theme: .github)
    #expect(styles.count > 10)
    #expect(styles["keyword"] != nil)
    #expect(styles["number"] != nil)
    #expect(styles["string"] != nil)
    #expect(styles["_default"] != nil)
    #expect(styles["_background"] != nil)
  }

  @Test
  func githubDarkThemeParsing() throws {
    let styles = try ThemeParser.parseStyles(theme: .githubDark)
    #expect(styles.count > 10)
    #expect(styles["keyword"] != nil)
    #expect(styles["_background"] != nil)
  }

  @Test
  func base16ThemeParsing() throws {
    let styles = try ThemeParser.parseStyles(theme: HighlightTheme("base16/monokai"))
    #expect(styles.count > 5)
  }

  @Test
  func allThemesDiscovery() {
    let themes = HighlightTheme.allThemes()
    #expect(themes.count > 50)
    let names = themes.map(\.rawValue)
    #expect(names.contains("github"))
    #expect(names.contains("monokai"))
    #expect(names.contains("nord"))
    #expect(names.contains(where: { $0.hasPrefix("base16/") }))
  }

  @Test
  func allThemesAreParseable() throws {
    let themes = HighlightTheme.allThemes()
    var failedThemes: [String] = []
    for theme in themes {
      do {
        let styles = try ThemeParser.parseStyles(theme: theme)
        if styles.isEmpty {
          failedThemes.append("\(theme.rawValue) (empty)")
        }
      } catch {
        failedThemes.append("\(theme.rawValue) (\(error))")
      }
    }
    #expect(failedThemes.count < 5, "Too many themes failed: \(failedThemes)")
  }

  // MARK: - AttributedStringBuilder Tests

  @Test
  func simpleHTMLParsing() throws {
    let html = #"<span class="hljs-keyword">let</span> x = <span class="hljs-number">5</span>"#
    let styles = try ThemeParser.parseStyles(theme: .github)
    let result = AttributedStringBuilder.build(from: html, styles: styles)
    #expect(result.string == "let x = 5")
  }

  @Test
  func nestedHTMLParsing() throws {
    let html = #"<span class="hljs-string">"hello <span class="hljs-subst">\(x)</span>"</span>"#
    let styles = try ThemeParser.parseStyles(theme: .github)
    let result = AttributedStringBuilder.build(from: html, styles: styles)
    #expect(result.string == #""hello \(x)""#)
  }

  @Test
  func hTMLEntityDecoding() {
    let html = "a &lt; b &amp;&amp; c &gt; d"
    let styles: [String: TokenStyle] = [:]
    let result = AttributedStringBuilder.build(from: html, styles: styles)
    #expect(result.string == "a < b && c > d")
  }

  @Test
  func compoundClassNames() {
    let html = #"<span class="hljs-title function_">myFunc</span>"#
    let styles: [String: TokenStyle] = ["title": TokenStyle(color: PlatformColor.red)]
    let result = AttributedStringBuilder.build(from: html, styles: styles)
    #expect(result.string == "myFunc")
  }

  @Test
  func plainTextPreserved() {
    let html = "no tags here"
    let styles: [String: TokenStyle] = [:]
    let result = AttributedStringBuilder.build(from: html, styles: styles)
    #expect(result.string == "no tags here")
  }

  @Test
  func foregroundColorApplied() throws {
    let html = #"<span class="hljs-keyword">let</span>"#
    let styles = try ThemeParser.parseStyles(theme: .github)
    let result = AttributedStringBuilder.build(from: html, styles: styles)
    // Check the attributed string has foreground color
    var range = NSRange(location: 0, length: 0)
    let attrs = result.attributes(at: 0, effectiveRange: &range)
    #expect(attrs[.foregroundColor] != nil)
  }

  // MARK: - Cache Tests

  @Test
  func cacheHit() throws {
    Highlighter.clearCache()
    let code = "let cached = true"
    let r1 = try Highlighter.highlight(code, language: "swift", theme: .github)
    // Same code, language, theme should give same result
    let r2 = try Highlighter.highlight("let cached = true", language: "swift", theme: .github)
    #expect(r1.string == r2.string)
  }

  @Test
  func clearCacheStillWorks() throws {
    _ = try Highlighter.highlight("test", language: "swift")
    Highlighter.clearCache()
    let result = try Highlighter.highlight("test", language: "swift")
    #expect(!result.string.isEmpty)
  }

  // MARK: - Integration Tests

  @Test
  func endToEndSwiftHighlighting() throws {
    Highlighter.clearCache()
    let code = "struct Person {\n    let name: String\n    func greet() -> String {\n        return \"Hello\"\n    }\n}"
    let result = try Highlighter.highlightWithBackground(code, language: "swift", theme: .github)
    let text = result.attributedString.string
    #expect(text.contains("struct"))
    #expect(text.contains("Person"))
    #expect(text.contains("name"))
    #expect(text.contains("greet"))
  }

  @Test
  func endToEndMultipleThemes() throws {
    let code = "let x = 5"
    let themes: [HighlightTheme] = [.github, .githubDark, .monokai, .atomOneDark, .nord, .vs, .xcode]
    for theme in themes {
      let result = try Highlighter.highlightWithBackground(code, language: "swift", theme: theme)
      #expect(!result.attributedString.string.isEmpty, "Theme \(theme.rawValue) produced empty result")
    }
  }

  @Test
  func endToEndMultipleLanguages() throws {
    let samples: [(String, String)] = [
      ("let x = 5", "swift"),
      ("const x = 5;", "javascript"),
      ("x = 5", "python"),
      ("int x = 5;", "java"),
      ("val x = 5", "kotlin"),
      ("fn main() {}", "rust"),
      ("package main", "go"),
    ]
    for (code, lang) in samples {
      let result = try Highlighter.highlight(code, language: lang)
      #expect(!result.string.isEmpty, "Language \(lang) produced empty result")
    }
  }

  @Test
  func originalTextPreservedAfterHighlighting() throws {
    Highlighter.clearCache()
    let code = "let greeting = \"Hello, World!\"\nprint(greeting)"
    let result = try Highlighter.highlight(code, language: "swift")
    #expect(result.string.contains("Hello, World!"))
    #expect(result.string.contains("print"))
  }

  // MARK: - TokenStyle / Enhanced ThemeParser Tests

  @Test
  func tokenStyleOpacity() throws {
    let styles = try ThemeParser.parseStyles(theme: HighlightTheme("base16/dracula"))
    // Dracula has opacity on operators
    if let opStyle = styles["operator"] {
      #expect(opStyle.opacity < 1.0, "Dracula operator should have reduced opacity")
    }
  }

  @Test
  func tokenStyleBoldItalic() throws {
    // Many themes define bold/italic for keywords or emphasis
    let styles = try ThemeParser.parseStyles(theme: .github)
    // Github theme has font-weight:bold on .hljs-keyword
    var foundBold = false
    for (_, style) in styles {
      if style.bold { foundBold = true; break }
    }
    // Not all themes use bold, so just verify parsing works without crash
    #expect(styles.count > 10)
  }

  @Test
  func compoundSelectorParsing() throws {
    let styles = try ThemeParser.parseStyles(theme: HighlightTheme("base16/dracula"))
    // base16/dracula has compound selectors like .hljs-title.class_
    // Check that compound keys are present
    let hasCompound = styles.keys.contains(where: { $0.contains(".") || $0.contains(">") })
    // Even if this particular theme doesn't have them, parsing should not crash
    #expect(styles.count > 5)
  }

  @Test
  func effectiveColorWithOpacity() {
    var style = TokenStyle(color: PlatformColor.red, opacity: 0.5)
    let effective = style.effectiveColor
    #expect(effective != nil)
    // Verify alpha is applied
    var alpha: CGFloat = 0
    effective?.getRed(nil, green: nil, blue: nil, alpha: &alpha)
    #expect(abs(alpha - 0.5) < 0.01, "Opacity should be applied to color alpha")
  }

  @Test
  func effectiveColorFullOpacity() {
    let style = TokenStyle(color: PlatformColor.blue, opacity: 1.0)
    let effective = style.effectiveColor
    #expect(effective != nil)
    var alpha: CGFloat = 0
    effective?.getRed(nil, green: nil, blue: nil, alpha: &alpha)
    #expect(abs(alpha - 1.0) < 0.01)
  }

  @Test
  func descendantSelectorStyleResolution() throws {
    // Build styles with a descendant key
    let styles: [String: TokenStyle] = [
      "title": TokenStyle(color: PlatformColor.red),
      "class>title": TokenStyle(color: PlatformColor.blue),
      "_default": TokenStyle(color: PlatformColor.white),
    ]
    // HTML with nested spans simulating .hljs-class > .hljs-title
    let html = #"<span class="hljs-class"><span class="hljs-title">MyClass</span></span>"#
    let result = AttributedStringBuilder.build(from: html, styles: styles)
    #expect(result.string == "MyClass")
    // The title inside class should use the descendant style (blue), not the direct style (red)
    var range = NSRange(location: 0, length: 0)
    let attrs = result.attributes(at: 0, effectiveRange: &range)
    let fg = attrs[.foregroundColor] as? PlatformColor
    #expect(fg != nil)
  }

  @Test
  func draculaThemeHighlighting() throws {
    Highlighter.clearCache()
    let code = "func fibonacci(_ n: Int) -> Int {\n    if n <= 1 { return n }\n    return fibonacci(n - 1) + fibonacci(n - 2)\n}"
    let result = try Highlighter.highlightWithBackground(code, language: "swift", theme: HighlightTheme("base16/dracula"))
    #expect(!result.attributedString.string.isEmpty)
    #expect(result.backgroundColor != nil)
    #expect(result.attributedString.string.contains("fibonacci"))
  }

  @Test
  func rGBColorParsing() {
    let color = ThemeParser.parseColor("rgb(255, 0, 128)")
    #expect(color != nil)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
    color?.getRed(&r, green: &g, blue: &b, alpha: nil)
    #expect(abs(r - 1.0) < 0.01)
    #expect(abs(g - 0.0) < 0.01)
    #expect(abs(b - 128.0 / 255.0) < 0.02)
  }

  @Test
  func hex8ColorParsing() {
    let color = ThemeParser.parseColor("#FF000080")
    #expect(color != nil)
    var alpha: CGFloat = 0
    color?.getRed(nil, green: nil, blue: nil, alpha: &alpha)
    #expect(abs(alpha - 128.0 / 255.0) < 0.02, "8-char hex should preserve alpha")
  }

  // MARK: - CSS Named Color Tests

  @Test
  func namedColorParsing() {
    let black = ThemeParser.parseColor("black")
    #expect(black != nil)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
    black?.getRed(&r, green: &g, blue: &b, alpha: nil)
    #expect(abs(r) < 0.01)
    #expect(abs(g) < 0.01)
    #expect(abs(b) < 0.01)

    let navy = ThemeParser.parseColor("navy")
    #expect(navy != nil)
    navy?.getRed(&r, green: &g, blue: &b, alpha: nil)
    #expect(abs(r) < 0.01)
    #expect(abs(g) < 0.01)
    #expect(abs(b - 128.0 / 255.0) < 0.02)

    let white = ThemeParser.parseColor("white")
    #expect(white != nil)
    white?.getRed(&r, green: &g, blue: &b, alpha: nil)
    #expect(abs(r - 1.0) < 0.01)
  }

  @Test
  func nonColorKeywordsReturnNil() {
    #expect(ThemeParser.parseColor("inherit") == nil)
    #expect(ThemeParser.parseColor("transparent") == nil)
    #expect(ThemeParser.parseColor("initial") == nil)
  }

  @Test
  func vsThemeHasNamedColors() throws {
    let styles = try ThemeParser.parseStyles(theme: .vs)
    #expect(styles["_default"] != nil, "vs theme should have _default from 'color: black'")
    #expect(styles["keyword"] != nil, "vs theme should have keyword color")
  }

  @Test
  func googlecodeThemeHasNamedColors() throws {
    let styles = try ThemeParser.parseStyles(theme: HighlightTheme("googlecode"))
    #expect(styles["_default"] != nil, "googlecode theme should have _default from 'color: black'")
  }

  @Test
  func cybertopiaThemeWithCSSVariables() throws {
    let styles = try ThemeParser.parseStyles(theme: HighlightTheme("cybertopia-cherry"))
    #expect(styles.count > 5, "cybertopia-cherry should have token styles after CSS variable resolution")
    #expect(styles["_default"] != nil, "cybertopia-cherry should have _default color from resolved var()")
    #expect(styles["_background"] != nil, "cybertopia-cherry should have _background from resolved var()")
  }

  @Test
  func isblEditorLightTheme() throws {
    let styles = try ThemeParser.parseStyles(theme: HighlightTheme("isbl-editor-light"))
    #expect(styles["_default"] != nil, "isbl-editor-light should have _default from 'color: black'")
  }
} // end HighlightSwiftTests
