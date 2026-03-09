// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "HighlightSwift",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8),
  ],
  products: [
    .library(
      name: "HighlightSwift",
      targets: ["HighlightSwift"]
    ),
  ],
  targets: [
    .target(
      name: "HighlightSwift",
      resources: [
        .copy("Resources"),
      ]
    ),
    .testTarget(
      name: "HighlightSwiftTests",
      dependencies: ["HighlightSwift"]
    ),
    .executableTarget(
      name: "ExampleSwiftUI",
      dependencies: ["HighlightSwift"],
      path: "Example/ExampleSwiftUI"
    ),
    .executableTarget(
      name: "ExampleAppKit",
      dependencies: ["HighlightSwift"],
      path: "Example/ExampleAppKit"
    ),
  ]
)
