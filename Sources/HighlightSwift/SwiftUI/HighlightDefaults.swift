import SwiftUI

/// Shared defaults for highlight SwiftUI components.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
enum HighlightDefaults {
  static var backgroundColor: Color {
    #if canImport(UIKit)
    Color(UIColor.secondarySystemBackground)
    #elseif canImport(AppKit)
    Color(NSColor.controlBackgroundColor)
    #endif
  }
}
