import HighlightSwift
import SwiftUI

@main
struct ExampleApp: App {
  var body: some Scene {
    WindowGroup {
      #if os(macOS)
      ContentView()
        .frame(minWidth: 700, minHeight: 500)
      #else
      NavigationView {
        ContentView()
      }
      #endif
    }
  }
}
