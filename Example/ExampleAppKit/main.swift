#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
import HighlightSwift

// MARK: - Main Window Controller

class HighlightWindowController: NSWindowController {
  convenience init() {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
      styleMask: [.titled, .closable, .resizable, .miniaturizable],
      backing: .buffered,
      defer: false
    )
    window.title = "HighlightSwift — AppKit Example"
    window.center()
    self.init(window: window)
    window.contentViewController = HighlightViewController()
  }
}

// MARK: - View Controller

class HighlightViewController: NSViewController {
  private let inputTextView = NSTextView()
  private let outputTextView = NSTextView()
  private let languagePopup = NSPopUpButton()
  private let themePopup = NSPopUpButton()

  private let languages = [
    "swift", "javascript", "python", "rust", "go",
    "java", "kotlin", "c", "cpp", "csharp",
    "ruby", "php", "typescript", "html", "css",
    "sql", "bash", "json", "yaml", "markdown",
  ]

  private let sampleCode = """
  func fibonacci(_ n: Int) -> Int {
      if n <= 1 { return n }
      return fibonacci(n - 1) + fibonacci(n - 2)
  }

  let result = fibonacci(10)
  print("Result: \\(result)")
  """

  override func loadView() {
    view = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
    setupUI()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    inputTextView.string = sampleCode
    updateHighlight()
  }

  // MARK: - UI Setup

  private func setupUI() {
    // Toolbar area
    let toolbar = NSStackView()
    toolbar.orientation = .horizontal
    toolbar.spacing = 12
    toolbar.translatesAutoresizingMaskIntoConstraints = false

    let titleLabel = NSTextField(labelWithString: "HighlightSwift — AppKit Example")
    titleLabel.font = .boldSystemFont(ofSize: 16)

    languagePopup.addItems(withTitles: languages)
    languagePopup.target = self
    languagePopup.action = #selector(languageChanged)

    let themeNames = HighlightTheme.allThemes().map(\.rawValue)
    themePopup.addItems(withTitles: themeNames)
    if let idx = themeNames.firstIndex(of: "github") {
      themePopup.selectItem(at: idx)
    }
    themePopup.target = self
    themePopup.action = #selector(themeChanged)

    toolbar.addArrangedSubview(titleLabel)
    toolbar.addArrangedSubview(NSView()) // spacer
    toolbar.addArrangedSubview(makeLabel("Language:"))
    toolbar.addArrangedSubview(languagePopup)
    toolbar.addArrangedSubview(makeLabel("Theme:"))
    toolbar.addArrangedSubview(themePopup)

    // Input scroll view
    let inputScroll = NSScrollView()
    inputScroll.translatesAutoresizingMaskIntoConstraints = false
    inputScroll.hasVerticalScroller = true
    inputScroll.borderType = .bezelBorder
    inputTextView.isEditable = true
    inputTextView.isRichText = false
    inputTextView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
    inputTextView.autoresizingMask = [.width]
    inputTextView.isVerticallyResizable = true
    inputTextView.textContainer?.widthTracksTextView = true
    inputTextView.delegate = self
    inputScroll.documentView = inputTextView

    let inputLabel = NSTextField(labelWithString: "Code Input")
    inputLabel.font = .systemFont(ofSize: 12, weight: .semibold)
    inputLabel.textColor = .secondaryLabelColor
    inputLabel.translatesAutoresizingMaskIntoConstraints = false

    // Output scroll view
    let outputScroll = NSScrollView()
    outputScroll.translatesAutoresizingMaskIntoConstraints = false
    outputScroll.hasVerticalScroller = true
    outputScroll.borderType = .bezelBorder
    outputTextView.isEditable = false
    outputTextView.isRichText = true
    outputTextView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
    outputTextView.autoresizingMask = [.width]
    outputTextView.isVerticallyResizable = true
    outputTextView.textContainer?.widthTracksTextView = true
    outputTextView.isSelectable = true
    outputScroll.documentView = outputTextView

    let outputLabel = NSTextField(labelWithString: "Highlighted Output")
    outputLabel.font = .systemFont(ofSize: 12, weight: .semibold)
    outputLabel.textColor = .secondaryLabelColor
    outputLabel.translatesAutoresizingMaskIntoConstraints = false

    // Layout
    view.addSubview(toolbar)
    view.addSubview(inputLabel)
    view.addSubview(inputScroll)
    view.addSubview(outputLabel)
    view.addSubview(outputScroll)

    NSLayoutConstraint.activate([
      toolbar.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
      toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

      inputLabel.topAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: 16),
      inputLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

      inputScroll.topAnchor.constraint(equalTo: inputLabel.bottomAnchor, constant: 4),
      inputScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      inputScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      inputScroll.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),

      outputLabel.topAnchor.constraint(equalTo: inputScroll.bottomAnchor, constant: 12),
      outputLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

      outputScroll.topAnchor.constraint(equalTo: outputLabel.bottomAnchor, constant: 4),
      outputScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      outputScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      outputScroll.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
    ])
  }

  private func makeLabel(_ text: String) -> NSTextField {
    let label = NSTextField(labelWithString: text)
    label.font = .systemFont(ofSize: 13)
    return label
  }

  // MARK: - Actions

  @objc
  private func languageChanged(_: NSPopUpButton) {
    updateHighlight()
  }

  @objc
  private func themeChanged(_: NSPopUpButton) {
    updateHighlight()
  }

  private func updateHighlight() {
    let code = inputTextView.string
    let language = languages[languagePopup.indexOfSelectedItem]
    let themeName = themePopup.titleOfSelectedItem ?? "github"
    let theme = HighlightTheme(themeName)

    do {
      let result = try Highlighter.highlightWithBackground(
        code,
        language: language,
        theme: theme
      )
      outputTextView.textStorage?.setAttributedString(result.attributedString)
      if let bg = result.backgroundColor {
        outputTextView.backgroundColor = bg
      } else {
        outputTextView.backgroundColor = .textBackgroundColor
      }
    } catch {
      let errorStr = NSAttributedString(
        string: "Error: \(error)",
        attributes: [.foregroundColor: NSColor.systemRed]
      )
      outputTextView.textStorage?.setAttributedString(errorStr)
      outputTextView.backgroundColor = .textBackgroundColor
    }
  }
}

// MARK: - NSTextViewDelegate

extension HighlightViewController: NSTextViewDelegate {
  func textDidChange(_: Notification) {
    updateHighlight()
  }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
  var windowController: HighlightWindowController?

  func applicationDidFinishLaunching(_: Notification) {
    windowController = HighlightWindowController()
    windowController?.showWindow(nil)
  }

  func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
    true
  }
}

// MARK: - Entry Point

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

#else
import Foundation

print("ExampleAppKit is only supported on macOS. Use ExampleSwiftUI for cross-platform demos.")
#endif
