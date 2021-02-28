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
    .package(url: "https://github.com/akolov/AKButton.git", .upToNextMajor(from: "1.0.1")),
    .package(url: "https://github.com/Rightpoint/BonMot.git", .upToNextMajor(from: "5.6.0"))
  ],
  targets: [
    .target(
      name: "AKFullscreenActionSheet",
      dependencies: ["AKButton", "BonMot"]
    ),
  ]
)
