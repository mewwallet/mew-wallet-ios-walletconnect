// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "mew-wallet-ios-walletconnect",
  platforms: [
    .iOS(.v14)
  ],
  products: [
    .library(
      name: "mew-wallet-ios-walletconnect",
      targets: ["mew-wallet-ios-walletconnect"]),
    .library(
      name: "mew-wallet-ios-walletconnect-v2",
      targets: ["mew-wallet-ios-walletconnect-v2"])
  ],
  dependencies: [
    .package(url: "https://github.com/reown-com/reown-swift.git", exact: "1.4.1"),
    .package(url: "https://github.com/mewwallet/mew-wallet-ios-logger.git", .upToNextMajor(from: "2.0.0"))
  ],
  targets: [
    .target(
      name: "mew-wallet-ios-walletconnect",
      dependencies: [
        "mew-wallet-ios-walletconnect-v2"
      ],
      path: "Sources/mew-wallet-ios-walletconnect",
      resources: [
        .copy("Privacy/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .target(
      name: "mew-wallet-ios-walletconnect-v2",
      dependencies: [
        .product(name: "mew-wallet-ios-logger", package: "mew-wallet-ios-logger"),
        .product(name: "WalletConnect", package: "reown-swift"),
        .product(name: "WalletConnectNetworking", package: "reown-swift"),
        .product(name: "WalletConnectPush", package: "reown-swift"),
        .product(name: "ReownRouter", package: "reown-swift"),
        .product(name: "WalletConnectNotify", package: "reown-swift"),
        .product(name: "WalletConnectPairing", package: "reown-swift"),
        .product(name: "ReownWalletKit", package: "reown-swift"),
      ],
      path: "Sources/v2",
      resources: [
        .copy("Privacy/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency=complete")
      ]),
    .testTarget(
      name: "mew-wallet-ios-walletconnectTests",
      dependencies: [
        "mew-wallet-ios-walletconnect",
      ]),
  ]
)
