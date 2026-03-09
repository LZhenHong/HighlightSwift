import SwiftUI

/// An async version of `CodeText` that highlights code on a background thread.
/// Better for large code blocks or frequent updates.
///
/// Usage:
/// ```swift
/// CodeTextAsync("let x = 5", language: "swift")
///     .theme(.githubDark)
/// ```
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct CodeTextAsync: View, CodeViewConfigurable {
  private let code: String
  private let language: String
  public var style = CodeViewStyle()

  public init(_ code: String, language: String) {
    self.code = code
    self.language = language
  }

  public var body: some View {
    AsyncHighlightView(code: code, language: language, style: style)
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct AsyncHighlightView: View {
  let code: String
  let language: String
  let style: CodeViewStyle

  @State private var attributedString: AttributedString?
  @State private var backgroundColor: Color?

  var body: some View {
    CodeContentView(
      code: code,
      attributedString: attributedString,
      backgroundColor: backgroundColor,
      style: style,
      showPlaceholder: true
    )
    .task(id: HighlightInput(code: code, language: language, theme: style.theme)) {
      await performHighlight()
    }
  }

  private func performHighlight() async {
    let capturedCode = code
    let capturedLanguage = language
    let capturedTheme = style.theme

    let result: HighlightResult? = await Task.detached {
      try? Highlighter.highlightWithBackground(capturedCode, language: capturedLanguage, theme: capturedTheme)
    }.value

    guard !Task.isCancelled else { return }

    if let result {
      attributedString = AttributedString(result.attributedString)
      backgroundColor = result.backgroundColor.map(Color.init)
    } else {
      attributedString = nil
      backgroundColor = nil
    }
  }
}

private struct HighlightInput: Equatable {
  let code: String
  let language: String
  let theme: HighlightTheme
}
