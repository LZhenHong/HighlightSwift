import HighlightSwift
import SwiftUI

struct ContentView: View {
  @State private var selectedLanguage = "swift"
  @State private var selectedTheme: HighlightTheme = .github
  @State private var codeInput: String = sampleCodes["swift"] ?? ""
  @State private var highlightedText: NSAttributedString?
  @State private var backgroundColor: Color = .init(white: 0.97)
  @State private var errorMessage: String?
  @State private var allThemes: [HighlightTheme] = []

  static let sampleCodes: [String: String] = [
    "swift": """
    func fibonacci(_ n: Int) -> Int {
        if n <= 1 { return n }
        return fibonacci(n - 1) + fibonacci(n - 2)
    }

    let result = fibonacci(10)
    print("Result: \\(result)")
    """,
    "javascript": """
    function fibonacci(n) {
        if (n <= 1) return n;
        return fibonacci(n - 1) + fibonacci(n - 2);
    }

    const result = fibonacci(10);
    console.log(`Result: ${result}`);
    """,
    "python": """
    def fibonacci(n):
        if n <= 1:
            return n
        return fibonacci(n - 1) + fibonacci(n - 2)

    result = fibonacci(10)
    print(f"Result: {result}")
    """,
    "rust": """
    fn fibonacci(n: u32) -> u32 {
        if n <= 1 { return n; }
        fibonacci(n - 1) + fibonacci(n - 2)
    }

    fn main() {
        let result = fibonacci(10);
        println!("Result: {}", result);
    }
    """,
    "go": """
    package main

    import "fmt"

    func fibonacci(n int) int {
        if n <= 1 {
            return n
        }
        return fibonacci(n-1) + fibonacci(n-2)
    }

    func main() {
        result := fibonacci(10)
        fmt.Printf("Result: %d\\n", result)
    }
    """,
  ]

  private let languages = [
    "swift", "javascript", "python", "rust", "go",
    "java", "kotlin", "c", "cpp", "csharp",
    "ruby", "php", "typescript", "html", "css",
    "sql", "bash", "json", "yaml", "markdown",
  ]

  var body: some View {
    VStack(spacing: 16) {
      headerBar
      codeInputSection
      highlightedOutputSection
    }
    .padding()
    .onAppear {
      allThemes = HighlightTheme.allThemes()
      updateHighlight()
    }
    .onChange(of: selectedLanguage) { newLang in
      if let sample = Self.sampleCodes[newLang] {
        codeInput = sample
      }
      updateHighlight()
    }
    .onChange(of: selectedTheme) { _ in updateHighlight() }
    .onChange(of: codeInput) { _ in updateHighlight() }
  }

  // MARK: - Subviews

  private var headerBar: some View {
    HStack {
      Text("HighlightSwift — SwiftUI Example")
        .font(.title2.bold())

      Spacer()

      Picker("Language", selection: $selectedLanguage) {
        ForEach(languages, id: \.self) { lang in
          Text(lang).tag(lang)
        }
      }
      .frame(width: 150)

      Picker("Theme", selection: $selectedTheme) {
        ForEach(allThemes, id: \.rawValue) { theme in
          Text(theme.rawValue).tag(theme)
        }
      }
      .frame(width: 220)
    }
  }

  private var codeInputSection: some View {
    GroupBox("Code Input") {
      TextEditor(text: $codeInput)
        .font(.system(.body, design: .monospaced))
        .frame(minHeight: 120, maxHeight: 200)
    }
  }

  private var highlightedOutputSection: some View {
    GroupBox("Highlighted Output (\(allThemes.count) themes available)") {
      ScrollView {
        Group {
          if let errorMessage {
            Text(errorMessage)
              .foregroundColor(.red)
          } else if let highlightedText {
            Text(AttributedString(highlightedText))
              .font(.system(.body, design: .monospaced))
              .textSelection(.enabled)
          } else {
            Text("Loading...")
              .foregroundColor(.secondary)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
      }
      .frame(minHeight: 200)
      .background(
        RoundedRectangle(cornerRadius: 6)
          .fill(backgroundColor)
      )
    }
  }

  // MARK: - Highlighting

  /// Also demonstrates using ``CodeText`` and ``CodeTextAsync`` alongside
  /// direct ``Highlighter`` usage shown above.
  private func updateHighlight() {
    errorMessage = nil
    do {
      let result = try Highlighter.highlightWithBackground(
        codeInput,
        language: selectedLanguage,
        theme: selectedTheme
      )
      highlightedText = result.attributedString
      if let bg = result.backgroundColor {
        backgroundColor = Color(bg)
      } else {
        backgroundColor = Color(white: 0.97)
      }
    } catch {
      errorMessage = "Error: \(error)"
      highlightedText = nil
    }
  }
}
