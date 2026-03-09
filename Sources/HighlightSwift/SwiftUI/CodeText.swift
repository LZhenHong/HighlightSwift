import SwiftUI

/// A SwiftUI view that displays syntax-highlighted code.
///
/// Usage:
/// ```swift
/// CodeText("let x = 5", language: "swift")
///     .theme(.github)
///     .codeFont(.system(.body, design: .monospaced))
/// ```
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct CodeText: View, CodeViewConfigurable {
  private let code: String
  private let language: String
  public var style = CodeViewStyle()

  public init(_ code: String, language: String) {
    self.code = code
    self.language = language
  }

  public var body: some View {
    SyncHighlightView(code: code, language: language, style: style)
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct SyncHighlightView: View {
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
      showPlaceholder: false
    )
    .onAppear { highlight() }
    .onChange(of: code) { _ in highlight() }
    .onChange(of: language) { _ in highlight() }
    .onChange(of: style.theme) { _ in highlight() }
  }

  private func highlight() {
    do {
      let result = try Highlighter.highlightWithBackground(
        code, language: language, theme: style.theme
      )
      attributedString = AttributedString(result.attributedString)
      backgroundColor = result.backgroundColor.map(Color.init)
    } catch {
      attributedString = nil
      backgroundColor = nil
    }
  }
}
