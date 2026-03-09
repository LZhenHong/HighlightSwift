import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Parses CSS color values into platform-native colors.
/// Supports hex (3/6/8 char), rgb/rgba, and CSS named colors.
enum ColorParser {
  static func parse(_ string: String) -> PlatformColor? {
    let trimmed = string.trimmingCharacters(in: .whitespaces)

    if trimmed.hasPrefix("rgb") {
      return parseRGB(trimmed)
    }

    if let hex = namedColors[trimmed.lowercased()] {
      return parse(hex)
    }

    if nonColorKeywords.contains(trimmed) {
      return nil
    }

    return parseHex(trimmed)
  }

  // MARK: - Hex

  private static func parseHex(_ string: String) -> PlatformColor? {
    var hex = string.trimmingCharacters(in: CharacterSet(charactersIn: "#"))

    // Expand 3-char shorthand: #abc → #aabbcc
    if hex.count == 3 {
      hex = hex.map { "\($0)\($0)" }.joined()
    }

    // 8-char hex includes alpha: RRGGBBAA
    var alpha: CGFloat = 1.0
    if hex.count == 8 {
      let alphaHex = String(hex.suffix(2))
      hex = String(hex.prefix(6))
      var alphaInt: UInt64 = 0
      Scanner(string: alphaHex).scanHexInt64(&alphaInt)
      alpha = CGFloat(alphaInt) / 255.0
    }

    guard hex.count == 6 else { return nil }

    var rgb: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&rgb)

    let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
    let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
    let b = CGFloat(rgb & 0x0000FF) / 255.0

    return PlatformColor(red: r, green: g, blue: b, alpha: alpha)
  }

  // MARK: - RGB/RGBA

  private static func parseRGB(_ string: String) -> PlatformColor? {
    let inner = string
      .replacingOccurrences(of: "rgba(", with: "")
      .replacingOccurrences(of: "rgb(", with: "")
      .replacingOccurrences(of: ")", with: "")
    let parts = inner.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    guard parts.count >= 3,
          let r = Double(parts[0]),
          let g = Double(parts[1]),
          let b = Double(parts[2]) else { return nil }
    let a = parts.count >= 4 ? (Double(parts[3]) ?? 1.0) : 1.0
    return PlatformColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
  }

  // MARK: - Named Colors

  private static let nonColorKeywords: Set<String> = [
    "inherit", "transparent", "initial", "unset", "currentColor",
  ]

  private static let namedColors: [String: String] = [
    "black": "#000000",
    "white": "#ffffff",
    "red": "#ff0000",
    "green": "#008000",
    "blue": "#0000ff",
    "navy": "#000080",
    "teal": "#008080",
    "aqua": "#00ffff",
    "lime": "#00ff00",
    "maroon": "#800000",
    "purple": "#800080",
    "olive": "#808000",
    "gray": "#808080",
    "grey": "#808080",
    "silver": "#c0c0c0",
    "fuchsia": "#ff00ff",
    "yellow": "#ffff00",
    "orange": "#ffa500",
    "darkred": "#8b0000",
    "darkgreen": "#006400",
    "darkblue": "#00008b",
    "darkcyan": "#008b8b",
    "darkgray": "#a9a9a9",
    "darkgrey": "#a9a9a9",
    "lightgray": "#d3d3d3",
    "lightgrey": "#d3d3d3",
    "brown": "#a52a2a",
    "coral": "#ff7f50",
    "crimson": "#dc143c",
    "cyan": "#00ffff",
    "gold": "#ffd700",
    "indigo": "#4b0082",
    "ivory": "#fffff0",
    "khaki": "#f0e68c",
    "lavender": "#e6e6fa",
    "magenta": "#ff00ff",
    "orchid": "#da70d6",
    "pink": "#ffc0cb",
    "plum": "#dda0dd",
    "salmon": "#fa8072",
    "sienna": "#a0522d",
    "tan": "#d2b48c",
    "tomato": "#ff6347",
    "turquoise": "#40e0d0",
    "violet": "#ee82ee",
    "wheat": "#f5deb3",
  ]
}
