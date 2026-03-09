import Foundation
@testable import HighlightSwift
import Testing

@Suite(.serialized)
struct PerformanceBenchmarks {
  // MARK: - Sample Code Inputs

  private static let smallCode = "let x: Int = 5"

  private static let mediumCode = """
  func fibonacci(_ n: Int) -> Int {
      if n <= 1 { return n }
      return fibonacci(n - 1) + fibonacci(n - 2)
  }

  func quickSort(_ array: inout [Int], low: Int, high: Int) {
      if low < high {
          let pivot = partition(&array, low: low, high: high)
          quickSort(&array, low: low, high: pivot - 1)
          quickSort(&array, low: pivot + 1, high: high)
      }
  }

  func partition(_ array: inout [Int], low: Int, high: Int) -> Int {
      let pivot = array[high]
      var i = low - 1
      for j in low..<high {
          if array[j] <= pivot {
              i += 1
              array.swapAt(i, j)
          }
      }
      array.swapAt(i + 1, high)
      return i + 1
  }

  func binarySearch(_ array: [Int], target: Int) -> Int? {
      var low = 0
      var high = array.count - 1
      while low <= high {
          let mid = (low + high) / 2
          if array[mid] == target {
              return mid
          } else if array[mid] < target {
              low = mid + 1
          } else {
              high = mid - 1
          }
      }
      return nil
  }

  func mergeSort(_ array: [Int]) -> [Int] {
      guard array.count > 1 else { return array }
      let mid = array.count / 2
      let left = mergeSort(Array(array[..<mid]))
      let right = mergeSort(Array(array[mid...]))
      return merge(left, right)
  }

  func merge(_ left: [Int], _ right: [Int]) -> [Int] {
      var result: [Int] = []
      var i = 0, j = 0
      while i < left.count && j < right.count {
          if left[i] <= right[j] {
              result.append(left[i])
              i += 1
          } else {
              result.append(right[j])
              j += 1
          }
      }
      result.append(contentsOf: left[i...])
      result.append(contentsOf: right[j...])
      return result
  }
  """

  /// Generates realistic Swift source code of approximately the given line count.
  /// Produces varied syntax: structs, enums, protocols, functions, closures, generics.
  private static func generateSwiftCode(approximateLines: Int) -> String {
    var lines: [String] = []
    lines.append("import Foundation")
    lines.append("")

    // Protocol
    lines.append("protocol DataTransformable {")
    lines.append("    associatedtype Input")
    lines.append("    associatedtype Output")
    lines.append("    func transform(_ input: Input) throws -> Output")
    lines.append("    var identifier: String { get }")
    lines.append("}")
    lines.append("")

    // Generate structs with methods until we hit the target
    var structIndex = 0
    while lines.count < approximateLines {
      let methodCount = min(8, (approximateLines - lines.count) / 12)
      if methodCount <= 0 { break }

      lines.append("struct Module\(structIndex): DataTransformable {")
      lines.append("    typealias Input = [String]")
      lines.append("    typealias Output = [String]")
      lines.append("")
      lines.append("    let identifier: String")
      lines.append("    let version: Int")
      lines.append("    var isActive: Bool = true")
      lines.append("    private var cache: [String: Any] = [:]")
      lines.append("")

      for m in 0..<methodCount {
        if m == 0 {
          // Implement protocol requirement
          lines.append("    func transform(_ input: [String]) throws -> [String] {")
          lines.append("        guard isActive else { throw ProcessingError.inactive }")
          lines.append("        return input.map { $0.trimmingCharacters(in: .whitespaces) }")
          lines.append("            .filter { !$0.isEmpty }")
          lines.append("    }")
        } else if m % 3 == 0 {
          // Generic method with closure
          lines.append("    func apply\(m)<T: Comparable>(_ values: [T], predicate: (T) -> Bool) -> [T] {")
          lines.append("        var result: [T] = []")
          lines.append("        for value in values {")
          lines.append("            if predicate(value) {")
          lines.append("                result.append(value)")
          lines.append("            }")
          lines.append("        }")
          lines.append("        return result.sorted()")
          lines.append("    }")
        } else if m % 3 == 1 {
          // Async-style method with guard/switch
          lines.append("    func process\(m)(_ input: [String], mode: ProcessingMode) -> [String] {")
          lines.append("        guard !input.isEmpty else { return [] }")
          lines.append("        switch mode {")
          lines.append("        case .fast:")
          lines.append("            return input.prefix(10).map { $0.lowercased() }")
          lines.append("        case .thorough:")
          lines.append("            return input.map { $0.lowercased().trimmingCharacters(in: .whitespaces) }")
          lines.append("        case .custom(let limit):")
          lines.append("            return input.prefix(limit).map { $0.uppercased() }")
          lines.append("        }")
          lines.append("    }")
        } else {
          // Computed property + helper
          lines.append("    var metric\(m): Double {")
          lines.append("        let base = Double(version) * 1.5")
          lines.append("        let factor = isActive ? 2.0 : 0.5")
          lines.append("        return base * factor + Double(identifier.count)")
          lines.append("    }")
        }
        lines.append("")
      }
      lines.append("}")
      lines.append("")
      structIndex += 1

      // Add an enum every 3 structs
      if structIndex % 3 == 0, lines.count < approximateLines - 20 {
        lines.append("enum Result\(structIndex / 3)<T> {")
        lines.append("    case success(T)")
        lines.append("    case failure(ProcessingError)")
        lines.append("    case pending")
        lines.append("")
        lines.append("    var isSuccess: Bool {")
        lines.append("        if case .success = self { return true }")
        lines.append("        return false")
        lines.append("    }")
        lines.append("")
        lines.append("    func map<U>(_ transform: (T) -> U) -> Result\(structIndex / 3)<U> {")
        lines.append("        switch self {")
        lines.append("        case .success(let value): return .success(transform(value))")
        lines.append("        case .failure(let error): return .failure(error)")
        lines.append("        case .pending: return .pending")
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        lines.append("")
      }

      // Add a free function every 5 structs
      if structIndex % 5 == 0, lines.count < approximateLines - 15 {
        lines.append("func aggregate\(structIndex / 5)(_ collections: [[String]]) -> [String: Int] {")
        lines.append("    var frequency: [String: Int] = [:]")
        lines.append("    for collection in collections {")
        lines.append("        for item in collection {")
        lines.append("            frequency[item, default: 0] += 1")
        lines.append("        }")
        lines.append("    }")
        lines.append("    return frequency.filter { $0.value > 1 }")
        lines.append("}")
        lines.append("")
      }
    }

    // Supporting types at the end
    lines.append("enum ProcessingMode {")
    lines.append("    case fast")
    lines.append("    case thorough")
    lines.append("    case custom(Int)")
    lines.append("}")
    lines.append("")
    lines.append("enum ProcessingError: Error {")
    lines.append("    case inactive")
    lines.append("    case invalidInput(String)")
    lines.append("    case timeout")
    lines.append("}")

    return lines.joined(separator: "\n")
  }

  private static let largeCode: String = {
    var lines: [String] = []
    lines.append("import Foundation")
    lines.append("")
    lines.append("struct DataProcessor {")
    lines.append("    let name: String")
    lines.append("    let version: Int")
    lines.append("    var isEnabled: Bool = true")
    lines.append("")
    for i in 0..<15 {
      lines.append("    func process\(i)(_ input: [String]) -> [String] {")
      lines.append("        var result: [String] = []")
      lines.append("        for item in input {")
      lines.append("            let trimmed = item.trimmingCharacters(in: .whitespaces)")
      lines.append("            if !trimmed.isEmpty {")
      lines.append("                result.append(trimmed.lowercased())")
      lines.append("            }")
      lines.append("        }")
      lines.append("        return result")
      lines.append("    }")
      lines.append("")
    }
    lines.append("}")
    lines.append("")
    lines.append("enum Status: String, CaseIterable {")
    lines.append("    case pending = \"pending\"")
    lines.append("    case active = \"active\"")
    lines.append("    case completed = \"completed\"")
    lines.append("    case failed = \"failed\"")
    lines.append("    case cancelled = \"cancelled\"")
    lines.append("")
    lines.append("    var displayName: String {")
    lines.append("        switch self {")
    lines.append("        case .pending: return \"Pending\"")
    lines.append("        case .active: return \"Active\"")
    lines.append("        case .completed: return \"Completed\"")
    lines.append("        case .failed: return \"Failed\"")
    lines.append("        case .cancelled: return \"Cancelled\"")
    lines.append("        }")
    lines.append("    }")
    lines.append("")
    lines.append("    var isTerminal: Bool {")
    lines.append("        switch self {")
    lines.append("        case .completed, .failed, .cancelled: return true")
    lines.append("        default: return false")
    lines.append("        }")
    lines.append("    }")
    lines.append("}")
    lines.append("")
    for i in 0..<8 {
      lines.append("func transform\(i)(_ values: [Double]) -> [Double] {")
      lines.append("    return values.map { $0 * Double(\(i + 1)) }")
      lines.append("        .filter { $0 > 0 }")
      lines.append("        .sorted()")
      lines.append("}")
      lines.append("")
    }
    return lines.joined(separator: "\n")
  }()

  // ~1000 lines of realistic Swift code
  private static let hugeCode = generateSwiftCode(approximateLines: 1000)
  // ~5000 lines of realistic Swift code
  private static let massiveCode = generateSwiftCode(approximateLines: 5000)

  // MARK: - Timing Helper

  private func measureAndReport(
    name: String,
    iterations: Int,
    threshold: Duration,
    block: () throws -> Void
  ) rethrows {
    var durations: [Duration] = []
    let clock = ContinuousClock()
    for _ in 0..<iterations {
      let elapsed = try clock.measure { try block() }
      durations.append(elapsed)
    }
    let sorted = durations.sorted()
    let median = sorted[sorted.count / 2]
    print("[PERF] \(name): median=\(median), min=\(sorted.first!), max=\(sorted.last!)")
    #expect(median < threshold, "Performance regression: \(name) median \(median) exceeded threshold \(threshold)")
  }

  // MARK: - Engine Highlight Benchmarks

  @Test
  func benchmarkEngineHighlightSmall() throws {
    // Warmup: ensure language is loaded
    _ = try HighlightEngine.shared.highlight(Self.smallCode, language: "swift")

    try measureAndReport(
      name: "EngineHighlightSmall",
      iterations: 10,
      threshold: .milliseconds(50)
    ) {
      _ = try HighlightEngine.shared.highlight(Self.smallCode, language: "swift")
    }
  }

  @Test
  func benchmarkEngineHighlightMedium() throws {
    _ = try HighlightEngine.shared.highlight(Self.mediumCode, language: "swift")

    try measureAndReport(
      name: "EngineHighlightMedium",
      iterations: 5,
      threshold: .milliseconds(200)
    ) {
      _ = try HighlightEngine.shared.highlight(Self.mediumCode, language: "swift")
    }
  }

  @Test
  func benchmarkEngineHighlightLarge() throws {
    _ = try HighlightEngine.shared.highlight(Self.largeCode, language: "swift")

    try measureAndReport(
      name: "EngineHighlightLarge",
      iterations: 3,
      threshold: .milliseconds(500)
    ) {
      _ = try HighlightEngine.shared.highlight(Self.largeCode, language: "swift")
    }
  }

  // MARK: - Theme Parsing Benchmarks

  @Test
  func benchmarkThemeParsingGithub() throws {
    try measureAndReport(
      name: "ThemeParsingGithub",
      iterations: 10,
      threshold: .milliseconds(20)
    ) {
      _ = try ThemeParser.parseStyles(theme: .github)
    }
  }

  @Test
  func benchmarkThemeParsingAllThemes() throws {
    let allThemes = HighlightTheme.allThemes()
    let clock = ContinuousClock()
    let elapsed = try clock.measure {
      for theme in allThemes {
        _ = try ThemeParser.parseStyles(theme: theme)
      }
    }
    print("[PERF] ThemeParsingAllThemes: total=\(elapsed) (\(allThemes.count) themes)")
    #expect(elapsed < .seconds(10), "Performance regression: parsing all \(allThemes.count) themes took \(elapsed)")
  }

  // MARK: - AttributedString Building Benchmarks

  @Test
  func benchmarkAttributedStringSmall() throws {
    let html = try HighlightEngine.shared.highlight(Self.smallCode, language: "swift")
    let styles = try ThemeParser.parseStyles(theme: .github)

    measureAndReport(
      name: "AttributedStringSmall",
      iterations: 20,
      threshold: .milliseconds(10)
    ) {
      _ = AttributedStringBuilder.build(from: html, styles: styles)
    }
  }

  @Test
  func benchmarkAttributedStringLarge() throws {
    let html = try HighlightEngine.shared.highlight(Self.largeCode, language: "swift")
    let styles = try ThemeParser.parseStyles(theme: .github)

    measureAndReport(
      name: "AttributedStringLarge",
      iterations: 5,
      threshold: .milliseconds(100)
    ) {
      _ = AttributedStringBuilder.build(from: html, styles: styles)
    }
  }

  // MARK: - Full Pipeline Benchmarks

  @Test
  func benchmarkFullPipelineColdCache() throws {
    // Warmup engine only (load language)
    _ = try HighlightEngine.shared.highlight(Self.mediumCode, language: "swift")

    try measureAndReport(
      name: "FullPipelineColdCache",
      iterations: 5,
      threshold: .milliseconds(100)
    ) {
      Highlighter.clearCache()
      _ = try Highlighter.highlight(Self.mediumCode, language: "swift", theme: .github)
    }
  }

  @Test
  func benchmarkFullPipelineWarmCache() throws {
    // Prime the cache
    _ = try Highlighter.highlight(Self.mediumCode, language: "swift", theme: .github)

    try measureAndReport(
      name: "FullPipelineWarmCache",
      iterations: 20,
      threshold: .milliseconds(30)
    ) {
      _ = try Highlighter.highlight(Self.mediumCode, language: "swift", theme: .github)
    }
  }

  // MARK: - Stress Tests (Super Large Files)

  @Test
  func stressEngineHighlightHuge() throws {
    // ~1000 lines — verify JSContext handles large input
    _ = try HighlightEngine.shared.highlight(Self.hugeCode, language: "swift")

    try measureAndReport(
      name: "StressEngineHuge(~1000 lines)",
      iterations: 3,
      threshold: .seconds(2)
    ) {
      _ = try HighlightEngine.shared.highlight(Self.hugeCode, language: "swift")
    }
  }

  @Test
  func stressEngineHighlightMassive() throws {
    // ~5000 lines — push JSContext to its limits
    _ = try HighlightEngine.shared.highlight(Self.massiveCode, language: "swift")

    try measureAndReport(
      name: "StressEngineMassive(~5000 lines)",
      iterations: 2,
      threshold: .seconds(10)
    ) {
      _ = try HighlightEngine.shared.highlight(Self.massiveCode, language: "swift")
    }
  }

  @Test
  func stressAttributedStringHuge() throws {
    // Build attributed string from ~1000 line highlight output
    let html = try HighlightEngine.shared.highlight(Self.hugeCode, language: "swift")
    let styles = try ThemeParser.parseStyles(theme: .github)

    let spanCount = html.components(separatedBy: "<span").count - 1
    print("[PERF] StressAttributedStringHuge: HTML contains \(spanCount) spans, \(html.count) chars")

    measureAndReport(
      name: "StressAttributedStringHuge(~1000 lines)",
      iterations: 3,
      threshold: .seconds(1)
    ) {
      _ = AttributedStringBuilder.build(from: html, styles: styles)
    }
  }

  @Test
  func stressAttributedStringMassive() throws {
    // Build attributed string from ~5000 line highlight output
    let html = try HighlightEngine.shared.highlight(Self.massiveCode, language: "swift")
    let styles = try ThemeParser.parseStyles(theme: .github)

    let spanCount = html.components(separatedBy: "<span").count - 1
    print("[PERF] StressAttributedStringMassive: HTML contains \(spanCount) spans, \(html.count) chars")

    measureAndReport(
      name: "StressAttributedStringMassive(~5000 lines)",
      iterations: 2,
      threshold: .seconds(5)
    ) {
      _ = AttributedStringBuilder.build(from: html, styles: styles)
    }
  }

  @Test
  func stressFullPipelineHuge() throws {
    // End-to-end ~1000 lines, cold cache
    _ = try HighlightEngine.shared.highlight(Self.hugeCode, language: "swift")

    try measureAndReport(
      name: "StressFullPipelineHuge(~1000 lines)",
      iterations: 3,
      threshold: .seconds(3)
    ) {
      Highlighter.clearCache()
      _ = try Highlighter.highlight(Self.hugeCode, language: "swift", theme: .githubDark)
    }
  }

  @Test
  func stressFullPipelineMassive() throws {
    // End-to-end ~5000 lines, cold cache
    _ = try HighlightEngine.shared.highlight(Self.massiveCode, language: "swift")

    try measureAndReport(
      name: "StressFullPipelineMassive(~5000 lines)",
      iterations: 2,
      threshold: .seconds(15)
    ) {
      Highlighter.clearCache()
      _ = try Highlighter.highlight(Self.massiveCode, language: "swift", theme: .githubDark)
    }
  }

  @Test
  func stressScalingLinearity() throws {
    // Verify time scales roughly linearly (not exponentially) with input size
    _ = try HighlightEngine.shared.highlight(Self.largeCode, language: "swift")
    _ = try HighlightEngine.shared.highlight(Self.hugeCode, language: "swift")
    _ = try HighlightEngine.shared.highlight(Self.massiveCode, language: "swift")

    let clock = ContinuousClock()

    // Measure ~200 lines
    let smallTime = try clock.measure {
      _ = try HighlightEngine.shared.highlight(Self.largeCode, language: "swift")
    }

    // Measure ~1000 lines
    let hugeTime = try clock.measure {
      _ = try HighlightEngine.shared.highlight(Self.hugeCode, language: "swift")
    }

    // Measure ~5000 lines
    let massiveTime = try clock.measure {
      _ = try HighlightEngine.shared.highlight(Self.massiveCode, language: "swift")
    }

    func toMs(_ d: Duration) -> Double {
      Double(d.components.seconds) * 1000.0 + Double(d.components.attoseconds) / 1_000_000_000_000_000.0
    }

    let smallMs = toMs(smallTime)
    let hugeMs = toMs(hugeTime)
    let massiveMs = toMs(massiveTime)

    // Ratio of time increase vs size increase
    // ~200 → ~1000 = 5x size, time should be < 15x (allowing superlinear but not exponential)
    // ~200 → ~5000 = 25x size, time should be < 75x
    let hugeRatio = hugeMs / smallMs
    let massiveRatio = massiveMs / smallMs

    print("[PERF] ScalingLinearity: ~200 lines=\(String(format: "%.1f", smallMs))ms, ~1000 lines=\(String(format: "%.1f", hugeMs))ms, ~5000 lines=\(String(format: "%.1f", massiveMs))ms")
    print("[PERF] ScalingLinearity: hugeRatio=\(String(format: "%.1f", hugeRatio))x (expect <15x), massiveRatio=\(String(format: "%.1f", massiveRatio))x (expect <75x)")

    #expect(hugeRatio < 15.0, "~1000 line highlight took \(String(format: "%.1f", hugeRatio))x longer than ~200 lines (expected <15x)")
    #expect(massiveRatio < 75.0, "~5000 line highlight took \(String(format: "%.1f", massiveRatio))x longer than ~200 lines (expected <75x)")
  }

  // MARK: - Cache Speedup

  @Test
  func benchmarkCacheSpeedup() throws {
    // Warmup engine
    _ = try HighlightEngine.shared.highlight(Self.mediumCode, language: "swift")

    let clock = ContinuousClock()

    // Measure cold
    var coldDurations: [Duration] = []
    for _ in 0..<5 {
      Highlighter.clearCache()
      let elapsed = try clock.measure {
        _ = try Highlighter.highlight(Self.mediumCode, language: "swift", theme: .github)
      }
      coldDurations.append(elapsed)
    }

    // Prime cache
    _ = try Highlighter.highlight(Self.mediumCode, language: "swift", theme: .github)

    // Measure warm
    var warmDurations: [Duration] = []
    for _ in 0..<20 {
      let elapsed = try clock.measure {
        _ = try Highlighter.highlight(Self.mediumCode, language: "swift", theme: .github)
      }
      warmDurations.append(elapsed)
    }

    let coldMedian = coldDurations.sorted()[coldDurations.count / 2]
    let warmMedian = warmDurations.sorted()[warmDurations.count / 2]

    print("[PERF] CacheSpeedup: coldMedian=\(coldMedian), warmMedian=\(warmMedian)")

    // Convert to comparable values via components
    let coldNs = Double(coldMedian.components.seconds) * 1_000_000_000 + Double(coldMedian.components.attoseconds) / 1_000_000_000
    let warmNs = Double(warmMedian.components.seconds) * 1_000_000_000 + Double(warmMedian.components.attoseconds) / 1_000_000_000

    let ratio = coldNs / warmNs
    print("[PERF] CacheSpeedup: ratio=\(String(format: "%.1f", ratio))x")
    #expect(ratio > 2.0, "Cache speedup ratio \(String(format: "%.1f", ratio))x is below 2.0x threshold")
  }
}
