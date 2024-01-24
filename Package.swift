// swift-tools-version: 5.8

import PackageDescription

let package = Package(
  name: "EmptyUIKit",
  platforms: [
    .iOS(.v11),
    .macCatalyst(.v13)
  ],
  products: [
    .library(name: "EmptyUIKit", targets: ["EmptyUIKit"]),
  ],
  targets: [
    .target(name: "EmptyUIKit")
  ]
)
