import SwiftUI

/// View extension for applying code highlighting to any view container.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension View {
  /// Wraps the view in a code block with the theme's background color.
  func codeBlock(theme: HighlightTheme = .github, cornerRadius: CGFloat = 8) -> some View {
    modifier(CodeBlockModifier(theme: theme, cornerRadius: cornerRadius))
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct CodeBlockModifier: ViewModifier {
  let theme: HighlightTheme
  let cornerRadius: CGFloat

  @State private var backgroundColor: Color?

  func body(content: Content) -> some View {
    content
      .padding(12)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(backgroundColor ?? HighlightDefaults.backgroundColor)
      )
      .onAppear { loadBackground() }
      .onChange(of: theme) { _ in loadBackground() }
  }

  private func loadBackground() {
    if let styles = try? ThemeParser.parseStyles(theme: theme),
       let bg = styles["_background"]?.effectiveColor {
      backgroundColor = Color(bg)
    }
  }
}
