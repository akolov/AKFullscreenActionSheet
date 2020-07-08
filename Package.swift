// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AKFullscreenActionSheet",
  platforms: [
    .iOS(.v12)
  ],
  products: [
    .library(
      name: "AKFullscreenActionSheet",
      targets: ["AKFullscreenActionSheet"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/akolov/AKButton.git", .branch("master"))
  ],
  targets: [
    .target(
      name: "AKFullscreenActionSheet",
      dependencies: ["AKButton"]
    ),
  ]
)
