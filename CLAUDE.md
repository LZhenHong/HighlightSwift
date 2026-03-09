# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Build the library
swift build

# Run all tests
swift test

# Run a single test class
swift test --filter HighlightSwiftTests

# Run a single test method
swift test --filter HighlightSwiftTests.testHighlightSwift

# Run theme validation tests
swift test --filter ThemeValidation
```

## Architecture

HighlightSwift is a Swift wrapper around [highlight.js](https://highlightjs.org/) that produces `NSAttributedString` output. It supports 192 languages and 257 themes (81 top-level + 176 base16) across iOS 15+, macOS 12+, tvOS 15+, and watchOS 8+.

### Processing Pipeline

```
Source code string
  → HighlightEngine (JSCore executes highlight.js → HTML)
  → ThemeParser (CSS file → TokenStyle dictionary)
  → AttributedStringBuilder (HTML + styles → NSAttributedString)
  → HighlightResult (attributed string + background color)
```

### Core Modules (Sources/HighlightSwift/)

- **Highlighter.swift** — Public API facade. Defines `HighlightTheme`, `HighlightResult`, `HighlightError`, and static methods like `highlight(_:language:theme:)`. Entry point for all consumers.
- **HighlightEngine.swift** — Singleton that manages a `JSContext`, loads `highlight.min.js`, and dynamically loads language modules from `Resources/languages/`. Uses parameter injection (not string interpolation) to avoid JS injection.
- **ThemeParser.swift** — Parses CSS theme files into `TokenStyle` dictionaries. Defines `PlatformColor` typealias (`UIColor`/`NSColor`) and `TokenStyle` struct (color, opacity, bold, italic, `effectiveColor`). Handles hex/RGB/RGBA colors, opacity, bold/italic, compound selectors (`.hljs-title.function_`), and descendant selectors (`.hljs-class > .hljs-title`). Special keys: `_default` (text color), `_background` (background color).
- **AttributedStringBuilder.swift** — Converts highlight.js HTML output (nested `<span class="hljs-*">`) into `NSAttributedString` with proper style inheritance. Uses `#if canImport(AppKit)` / `#if canImport(UIKit)` for cross-platform font handling.
- **HighlightCache.swift** — Thread-safe (NSLock) dual-layer LRU cache: HTML cache (code+language → HTML, max 128) and style cache (theme → token styles, max 32).

### SwiftUI Layer (Sources/HighlightSwift/SwiftUI/)

- **CodeText.swift** — Synchronous SwiftUI view with modifier chain (`.theme()`, `.codeFont()`, `.showBackground()`)
- **CodeTextAsync.swift** — Async variant using `Task.detached` with cancellation support
- **HighlightModifier.swift** — `.codeBlock(theme:cornerRadius:)` view modifier
- **HighlightDefaults.swift** — Platform-specific default colors

### Resources

- `Resources/highlight.min.js` — Core highlight.js library
- `Resources/languages/*.min.js` — 192 language grammar files, loaded on-demand by HighlightEngine
- `Resources/styles/*.css` — 257 theme CSS files (81 top-level + 176 in `base16/` subdirectory), discovered dynamically by `allThemes()`

### Key Design Decisions

- **HighlightEngine and HighlightCache are singletons** — accessed via `.shared`
- **Languages are lazy-loaded** — `ensureLanguageLoaded(_:)` loads JS files only when first requested
- **Themes are discovered at runtime** — `allThemes()` scans the Resources/styles bundle directory
- **Cross-platform via conditional compilation** — `UIFont`/`NSFont`, `UIColor`/`NSColor` abstracted at usage sites
- **JS injection prevention** — HighlightEngine passes code via `JSValue`/`setObject` instead of string interpolation
- **Tests are serialized** — `@Suite(.serialized)` because `HighlightEngine` uses a shared `JSContext` that is not thread-safe

### Example Targets

- **ExampleSwiftUI** (`Example/ExampleSwiftUI/`) — `ExampleApp.swift` (entry point) + `ContentView.swift` (language/theme pickers, live code editor)
- **ExampleAppKit** (`Example/ExampleAppKit/`) — `main.swift` (window controller, text views, AppKit delegate; macOS-only, guarded by `#if canImport(AppKit)`)

## Performance Gate

All changes must pass performance benchmarks before committing:

```bash
swift test --filter PerformanceBenchmarks
```

Acceptance criteria are defined as threshold assertions in
`Tests/HighlightSwiftTests/PerformanceBenchmarks.swift`.
If any benchmark fails, the change must be optimized or the
regression investigated before merge.

## Tests

Tests are in `Tests/HighlightSwiftTests/`:
- **HighlightSwiftTests.swift** — 41 tests covering engine init, API, parsing, caching, TokenStyle/opacity, color parsing, descendant selectors, and end-to-end integration
- **ThemeValidation.swift** — 11 tests validating all themes parse correctly, color accuracy across popular themes (GitHub, GitHub Dark, Monokai Sublime, Atom One Dark, Nord, VS 2015, Dracula), opacity parsing, descendant selector isolation, and cross-theme highlight output
- **PerformanceBenchmarks.swift** — 10 benchmarks covering engine highlight (small/medium/large), theme parsing (single + all 257), attributed string building (small/large), full pipeline (cold/warm cache), and cache speedup ratio validation
