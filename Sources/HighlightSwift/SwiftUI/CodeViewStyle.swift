import SwiftUI

/// Shared configuration for code highlighting views.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct CodeViewStyle {
  var theme: HighlightTheme = .github
  var font: Font = .system(.body, design: .monospaced)
  var showBackground: Bool = true
  var cornerRadius: CGFloat = 8
  var padding: CGFloat = 12
}

/// Protocol for views that display syntax-highlighted code.
/// Provides shared modifier methods via a default extension.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol CodeViewConfigurable {
  var style: CodeViewStyle { get set }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension CodeViewConfigurable {
  func theme(_ theme: HighlightTheme) -> Self {
    var copy = self
    copy.style.theme = theme
    return copy
  }

  func codeFont(_ font: Font) -> Self {
    var copy = self
    copy.style.font = font
    return copy
  }

  func showBackground(_ show: Bool) -> Self {
    var copy = self
    copy.style.showBackground = show
    return copy
  }

  func codeCornerRadius(_ radius: CGFloat) -> Self {
    var copy = self
    copy.style.cornerRadius = radius
    return copy
  }

  func codePadding(_ padding: CGFloat) -> Self {
    var copy = self
    copy.style.padding = padding
    return copy
  }
}

/// Shared view builder for the highlighted code output area.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct CodeContentView: View {
  let code: String
  let attributedString: AttributedString?
  let backgroundColor: Color?
  let style: CodeViewStyle
  let showPlaceholder: Bool

  var body: some View {
    Group {
      if let attributedString {
        Text(attributedString)
          .font(style.font)
          .textSelection(.enabled)
      } else {
        let text = Text(code).font(style.font).foregroundColor(.secondary)
        if showPlaceholder {
          text.redacted(reason: .placeholder)
        } else {
          text
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(style.padding)
    .background(
      Group {
        if style.showBackground {
          RoundedRectangle(cornerRadius: style.cornerRadius)
            .fill(backgroundColor ?? HighlightDefaults.backgroundColor)
        } else {
          Color.clear
        }
      }
    )
  }
}
