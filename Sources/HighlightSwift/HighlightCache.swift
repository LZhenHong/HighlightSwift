import Foundation

/// LRU cache for highlight results to avoid re-highlighting identical code.
final class HighlightCache {
  static let shared = HighlightCache()

  private struct CacheKey: Hashable {
    let code: String
    let language: String
  }

  private struct ThemeCacheKey: Hashable {
    let theme: String
  }

  private var htmlCache: [CacheKey: String] = [:]
  private var htmlAccessOrder: [CacheKey] = []
  private var stylesCache: [ThemeCacheKey: [String: TokenStyle]] = [:]

  private let maxHTMLEntries: Int
  private let maxThemeEntries: Int
  private let lock = NSLock()

  init(maxHTMLEntries: Int = 128, maxThemeEntries: Int = 32) {
    self.maxHTMLEntries = maxHTMLEntries
    self.maxThemeEntries = maxThemeEntries
  }

  // MARK: - HTML Cache

  func cachedHTML(code: String, language: String) -> String? {
    lock.lock()
    defer { lock.unlock() }
    let key = CacheKey(code: code, language: language)
    guard let value = htmlCache[key] else { return nil }
    // Move to end (most recently used)
    if let idx = htmlAccessOrder.firstIndex(of: key) {
      htmlAccessOrder.remove(at: idx)
      htmlAccessOrder.append(key)
    }
    return value
  }

  func setHTML(_ html: String, code: String, language: String) {
    lock.lock()
    defer { lock.unlock() }
    let key = CacheKey(code: code, language: language)
    htmlCache[key] = html
    if let idx = htmlAccessOrder.firstIndex(of: key) {
      htmlAccessOrder.remove(at: idx)
    }
    htmlAccessOrder.append(key)
    // Evict oldest if over limit
    while htmlAccessOrder.count > maxHTMLEntries {
      let evicted = htmlAccessOrder.removeFirst()
      htmlCache.removeValue(forKey: evicted)
    }
  }

  // MARK: - Styles Cache

  func cachedStyles(_ theme: HighlightTheme) -> [String: TokenStyle]? {
    lock.lock()
    defer { lock.unlock() }
    return stylesCache[ThemeCacheKey(theme: theme.rawValue)]
  }

  func setStyles(_ styles: [String: TokenStyle], for theme: HighlightTheme) {
    lock.lock()
    defer { lock.unlock() }
    stylesCache[ThemeCacheKey(theme: theme.rawValue)] = styles
    if stylesCache.count > maxThemeEntries {
      if let first = stylesCache.keys.first {
        stylesCache.removeValue(forKey: first)
      }
    }
  }

  /// Clear all caches.
  func clearAll() {
    lock.lock()
    defer { lock.unlock() }
    htmlCache.removeAll()
    htmlAccessOrder.removeAll()
    stylesCache.removeAll()
  }
}
