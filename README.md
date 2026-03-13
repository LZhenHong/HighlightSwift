# HighlightSwift

A Swift syntax highlighting library powered by [highlight.js](https://highlightjs.org/). Produces native `NSAttributedString` output with **192 languages** and **257 themes** — no web views required.

[![Swift 5.10+](https://img.shields.io/badge/Swift-5.10+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015+%20|%20macOS%2012+%20|%20tvOS%2015+%20|%20watchOS%208+-blue.svg)](https://developer.apple.com)
[![Code License: MIT](https://img.shields.io/badge/Code%20License-MIT-green.svg)](LICENSE)
[![Bundled Assets: See Notices](https://img.shields.io/badge/Bundled%20Assets-See%20Notices-blue.svg)](THIRD_PARTY_NOTICES.md)

## Features

- **192 languages** — Swift, Python, JavaScript, Rust, Go, and [many more](Sources/HighlightSwift/Resources/languages/)
- **257 themes** — GitHub, Monokai, Atom One Dark, Nord, 176 base16 themes, and [all highlight.js themes](Sources/HighlightSwift/Resources/styles/)
- **Native output** — Returns `NSAttributedString`, ready for `UILabel`, `NSTextView`, or SwiftUI `Text`
- **SwiftUI views** — Drop-in `CodeText` and `CodeTextAsync` components with modifier-based API
- **Fast** — JavaScriptCore engine with dual-layer LRU caching
- **Cross-platform** — iOS, macOS, tvOS, and watchOS from a single codebase

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/LZhenHong/HighlightSwift.git", from: "0.0.1")
]
```

Or in Xcode: **File > Add Package Dependencies**, then enter the repository URL.

## Quick Start

### Direct API

```swift
import HighlightSwift

let code = """
func greet(_ name: String) -> String {
  return "Hello, \\(name)!"
}
"""

// Get an attributed string
let highlighted = try Highlighter.highlight(code, language: "swift", theme: .github)

// Get attributed string + background color
let result = try Highlighter.highlightWithBackground(code, language: "swift", theme: .githubDark)
textView.attributedText = result.attributedString
textView.backgroundColor = result.backgroundColor
```

### SwiftUI — CodeText

Synchronous highlighting, ideal for small-to-medium code blocks:

```swift
import SwiftUI
import HighlightSwift

struct ContentView: View {
  var body: some View {
    CodeText("let x = 42", language: "swift")
      .theme(.atomOneDark)
      .codeFont(.system(.body, design: .monospaced))
      .showBackground(true)
      .codeCornerRadius(12)
      .codePadding(16)
    }
}
```

### SwiftUI — CodeTextAsync

Async highlighting on a background thread, better for large code blocks or frequent updates:

```swift
CodeTextAsync(longCodeString, language: "python")
  .theme(.monokai)
```

### SwiftUI — View Modifier

Apply a themed code block background to any view:

```swift
Text(attributedCode)
  .codeBlock(theme: .nord, cornerRadius: 8)
```

### AppKit

```swift
import AppKit
import HighlightSwift

let result = try Highlighter.highlightWithBackground(
  code,
  language: "swift",
  theme: .github
)
textView.textStorage?.setAttributedString(result.attributedString)
textView.backgroundColor = result.backgroundColor ?? .textBackgroundColor
```

## API Reference

### Highlighter

| Method | Description |
|--------|-------------|
| `Highlighter.highlight(_:language:theme:)` | Returns `NSAttributedString` with syntax highlighting |
| `Highlighter.highlightWithBackground(_:language:theme:)` | Returns `HighlightResult` containing attributed string and background color |
| `Highlighter.listLanguages()` | Returns all available language identifiers |
| `Highlighter.clearCache()` | Clears both HTML and theme style caches |

### HighlightTheme

Create from any highlight.js theme name, or use built-in constants:

**Light themes:** `.github`, `.atomOneLight`, `.vs`, `.xcode`, `.idea`, `.intellijLight`, `.stackoverflowLight`, `.default_`

**Dark themes:** `.githubDark`, `.githubDarkDimmed`, `.monokai`, `.monokaiSublime`, `.atomOneDark`, `.vs2015`, `.nord`, `.dark`, `.nightOwl`, `.obsidian`, `.tokyoNightDark`, `.rosePine`, `.shadesOfPurple`, `.sunburst`

```swift
// Use a built-in constant
let theme: HighlightTheme = .githubDark

// Or reference any theme by name (including base16/ subdirectory themes)
let theme = HighlightTheme("base16/dracula")

// Discover all available themes at runtime
let allThemes = HighlightTheme.allThemes()  // → [HighlightTheme]
```

### HighlightResult

```swift
public struct HighlightResult {
  public let attributedString: NSAttributedString
  public let backgroundColor: PlatformColor?    // UIColor or NSColor
}
```

### HighlightError

```swift
public enum HighlightError: Error {
  case engineInitFailed        // JavaScriptCore failed to initialize
  case highlightFailed         // highlight.js returned an error
  case themeNotFound           // CSS file not found in bundle
  case languageNotSupported    // Language grammar not available
}
```

### SwiftUI View Modifiers

Both `CodeText` and `CodeTextAsync` support:

| Modifier | Default | Description |
|----------|---------|-------------|
| `.theme(_:)` | `.github` | Highlight theme |
| `.codeFont(_:)` | `.system(.body, design: .monospaced)` | Font for the code text |
| `.showBackground(_:)` | `true` | Show/hide the background |
| `.codeCornerRadius(_:)` | `8` | Background corner radius |
| `.codePadding(_:)` | `12` | Inner padding |

## Architecture

```
Source code string
  → HighlightEngine (JavaScriptCore executes highlight.js → HTML)
  → ThemeParser (CSS theme file → token style dictionary)
  → AttributedStringBuilder (HTML + styles → NSAttributedString)
  → HighlightResult
```

- **HighlightEngine** — Singleton wrapping a `JSContext`. Loads `highlight.min.js` once, then lazy-loads individual language grammars on demand from bundled `.min.js` files.
- **ThemeParser** — Parses CSS into color/font-weight/font-style mappings. Supports hex, RGB/RGBA, opacity, compound selectors (`.hljs-title.function_`), and descendant selectors (`.hljs-class > .hljs-title`).
- **AttributedStringBuilder** — Walks highlight.js HTML output (`<span class="hljs-*">`), resolves styles with inheritance, and produces `NSAttributedString` with platform-appropriate monospaced fonts.
- **HighlightCache** — Thread-safe dual-layer LRU cache: HTML results (128 entries) and parsed theme styles (32 entries).

## Examples

The repository includes two example targets:

- **ExampleSwiftUI** — Cross-platform SwiftUI app with language/theme pickers and live code editing
- **ExampleAppKit** — Native macOS app with side-by-side input/output text views

Run them with:

```bash
swift run ExampleSwiftUI    # Requires macOS
swift run ExampleAppKit     # macOS only
```

## Performance Benchmarks

Run performance regression tests to verify no degradation in the rendering pipeline:

```bash
swift test --filter PerformanceBenchmarks
```

## Requirements

| Platform | Minimum Version |
|----------|----------------|
| iOS      | 15.0           |
| macOS    | 12.0           |
| tvOS     | 15.0           |
| watchOS  | 8.0            |
| Swift    | 5.10           |

## Third-Party Assets

HighlightSwift bundles `highlight.js`, language grammars, and theme CSS as
package resources. Those vendored assets keep their upstream notices and are
not relicensed under this repository's MIT license.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the redistribution
matrix, and
[Sources/HighlightSwift/Resources/ThirdPartyLicenses](Sources/HighlightSwift/Resources/ThirdPartyLicenses/)
for the license texts that ship with the package resources.

## License

HighlightSwift's first-party Swift source, tests, examples, and repository
project files are licensed under [MIT](LICENSE) — Copyright (c) 2026 Eden.

Bundled third-party resources under
[Sources/HighlightSwift/Resources](Sources/HighlightSwift/Resources/)
keep their original licenses and notices. See
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
