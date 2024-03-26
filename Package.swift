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
    .package(url: "https://github.com/WalletConnect/WalletConnectSwiftV2", exact: "1.11.0"),
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
        .product(name: "WalletConnect", package: "WalletConnectSwiftV2"),
        .product(name: "WalletConnectNetworking", package: "WalletConnectSwiftV2"),
        .product(name: "WalletConnectPush", package: "WalletConnectSwiftV2"),
        .product(name: "WalletConnectAuth", package: "WalletConnectSwiftV2"),
        .product(name: "WalletConnectRouter", package: "WalletConnectSwiftV2"),
        .product(name: "WalletConnectNotify", package: "WalletConnectSwiftV2"),
        .product(name: "WalletConnectSync", package: "WalletConnectSwiftV2"),
        .product(name: "WalletConnectPairing", package: "WalletConnectSwiftV2"),
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
