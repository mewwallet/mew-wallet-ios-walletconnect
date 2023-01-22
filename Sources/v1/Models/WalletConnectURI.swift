//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import Foundation
import CryptoSwift

public struct WalletConnectURI: Equatable, Hashable {
  public let topic: String
  public let version: String
  public let bridge: URL
  public let key: Data

  public var absoluteString: String {
    guard let bridge = bridge.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return "" }
    return "wc:\(topic)@\(version)?bridge=\(bridge)&key=\(key.toHexString())"
  }

  public init(topic: String, bridge: URL, key: Data) {
    self.version = "1"
    self.topic = topic
    self.bridge = bridge
    self.key = key
  }
  
  public init(string: String?) throws {
    guard let string, let components = Self.parseURIComponents(from: string) else { throw Error.invalidPairingURL }
    let query: [String: String]? = components.queryItems?.reduce(into: [:]) { $0[$1.name] = $1.value }
    
    guard let topic = components.user,
          let version = components.host,
          let bridgeString = query?["bridge"],
          let bridge = URL(string: bridgeString),
          let key = query?["key"] else { throw Error.invalidPairingParameters }
    
    guard version == "1" else { throw Error.invalidVersion }
    
    self.version = version
    self.topic = topic
    self.bridge = bridge
    self.key = Data(hex: key)
  }

  private static func parseURIComponents(from string: String) -> URLComponents? {
    guard string.hasPrefix("wc:") else { return nil }
    let string = !string.hasPrefix("wc://") ? string.replacingOccurrences(of: "wc:", with: "wc://") : string
    return URLComponents(string: string)
  }
}
