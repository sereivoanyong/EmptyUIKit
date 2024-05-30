// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "EmptyUIKit",
  platforms: [
    .iOS(.v13),
    .macCatalyst(.v13)
  ],
  products: [
    .library(name: "EmptyUIKit", targets: ["EmptyUIKit"]),
  ],
  targets: [
    .target(name: "EmptyUIKit")
  ]
)
