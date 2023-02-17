// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "mew-wallet-ios-walletconnect",
  platforms: [
    .iOS(.v14)
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "mew-wallet-ios-walletconnect",
      targets: ["mew-wallet-ios-walletconnect"]),
    .library(
      name: "mew-wallet-ios-walletconnect-v1",
      targets: ["mew-wallet-ios-walletconnect-v1"]),
    .library(
      name: "mew-wallet-ios-walletconnect-v2",
      targets: ["mew-wallet-ios-walletconnect-v2"])
  ],
  dependencies: [
    .package(url: "https://github.com/mewwallet/WalletConnectSwiftV2", branch: "feature/wcsession_created"),
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.4.0"),
    .package(url: "https://github.com/daltoniam/Starscream", from: "4.0.0"),
    .package(url: "git@github.com:mewwallet/mew-wallet-ios-logger.git", .upToNextMajor(from: "1.0.0"))
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "mew-wallet-ios-walletconnect",
      dependencies: [
        "mew-wallet-ios-walletconnect-v1",
        "mew-wallet-ios-walletconnect-v2"
      ],
      path: "Sources/mew-wallet-ios-walletconnect"
    ),
    .target(
      name: "mew-wallet-ios-walletconnect-v1",
      dependencies: [
        .product(name: "CryptoSwift", package: "CryptoSwift"),
        .product(name: "Starscream", package: "Starscream"),
        .product(name: "mew-wallet-ios-logger", package: "mew-wallet-ios-logger")
      ],
      path: "Sources/v1"),
    .target(
      name: "mew-wallet-ios-walletconnect-v2",
      dependencies: [
        .product(name: "WalletConnect", package: "WalletConnectSwiftV2"),
        .product(name: "WalletConnectNetworking", package: "WalletConnectSwiftV2"),
        .product(name: "WalletConnectEcho", package: "WalletConnectSwiftV2"),
        .product(name: "WalletConnectPush", package: "WalletConnectSwiftV2"),
        .product(name: "Starscream", package: "Starscream")
      ],
      path: "Sources/v2"),
    .testTarget(
      name: "mew-wallet-ios-walletconnectTests",
      dependencies: [
        "mew-wallet-ios-walletconnect",
        "mew-wallet-ios-walletconnect-v1"
      ]),
  ]
)
