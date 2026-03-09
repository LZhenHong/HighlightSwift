import Foundation
import JavaScriptCore

final class HighlightEngine {
  private static let _shared: Result<HighlightEngine, Error> = Result { try HighlightEngine() }

  static var shared: HighlightEngine {
    get throws { try _shared.get() }
  }

  private let context: JSContext
  private let lock = NSLock()

  init() throws {
    guard let context = JSContext() else {
      throw HighlightError.engineInitFailed
    }
    self.context = context
    try loadHighlightJS()
  }

  private func loadHighlightJS() throws {
    guard let url = Bundle.module.url(forResource: "highlight.min", withExtension: "js", subdirectory: "Resources"),
          let js = try? String(contentsOf: url, encoding: .utf8) else {
      throw HighlightError.engineInitFailed
    }

    // CDN build exposes `var hljs` as a global IIFE
    context.evaluateScript(js)

    guard let check = context.evaluateScript("typeof hljs !== 'undefined' && typeof hljs.highlight === 'function'"),
          check.toBool() else {
      throw HighlightError.engineInitFailed
    }
  }

  func highlight(_ code: String, language: String) throws -> String {
    lock.lock()
    defer { lock.unlock() }

    try ensureLanguageLoaded(language)

    // Pass code via JSValue to avoid escaping issues
    let codeValue = JSValue(object: code, in: context)
    context.setObject(codeValue, forKeyedSubscript: "__hs_code" as NSString)
    context.setObject(language, forKeyedSubscript: "__hs_lang" as NSString)

    let script = """
    (function() {
        try {
            return hljs.highlight(__hs_code, { language: __hs_lang }).value;
        } catch(e) {
            return null;
        }
    })()
    """

    guard let result = context.evaluateScript(script),
          !result.isNull,
          !result.isUndefined,
          let html = result.toString() else {
      throw HighlightError.highlightFailed
    }

    return html
  }

  func listLanguages() -> [String] {
    lock.lock()
    defer { lock.unlock() }
    guard let result = context.evaluateScript("hljs.listLanguages()"),
          let array = result.toArray() as? [String] else {
      return []
    }
    return array
  }

  private func ensureLanguageLoaded(_ language: String) throws {
    // Check if already available (built-in or previously loaded)
    // Use JSValue parameter passing to avoid JS injection
    context.setObject(language, forKeyedSubscript: "__hs_check_lang" as NSString)
    let check = context.evaluateScript("hljs.getLanguage(__hs_check_lang) !== undefined")
    if check?.toBool() == true {
      return
    }

    // Try loading from additional language files
    // CDN language files are self-registering: they call hljs.registerLanguage internally
    guard let langURL = Bundle.module.url(forResource: language, withExtension: "min.js", subdirectory: "Resources/languages")
      ?? Bundle.module.url(forResource: language, withExtension: "js", subdirectory: "Resources/languages"),
      let langJS = try? String(contentsOf: langURL, encoding: .utf8) else {
      throw HighlightError.languageNotSupported
    }

    context.evaluateScript(langJS)

    // Verify it registered (reuse the same safe variable)
    let verify = context.evaluateScript("hljs.getLanguage(__hs_check_lang) !== undefined")
    if verify?.toBool() != true {
      throw HighlightError.languageNotSupported
    }
  }
}
