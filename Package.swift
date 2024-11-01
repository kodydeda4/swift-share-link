// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swift-sharelink",
  platforms: [
    .iOS(.v13),
  ],
  products: [
    .library(name: "SwiftShareLink", targets: ["SwiftShareLink"]),
  ],
  targets: [
    .target(name: "SwiftShareLink"),
  ]
)
