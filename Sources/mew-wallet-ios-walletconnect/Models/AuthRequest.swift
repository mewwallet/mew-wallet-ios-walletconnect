//
//  File.swift
//
//
//  Created by Mikhail Nikanorov on 5/30/23.
//

import Foundation
import mew_wallet_ios_walletconnect_v2

public enum AuthRequest {
  public struct SignedAuthMessage: Sendable, Equatable{
    public let signature: String
    public let message: AuthMessage
  }
  
  public struct AuthMessage: Sendable, Equatable {
    public let chain: UInt64
    public let message: String
    public let payload: WCAuthPayload
    
    public func signed(signature: String) -> SignedAuthMessage {
      return SignedAuthMessage(signature: signature, message: self)
    }
  }
  case v2(request: WC2.AuthRequest, context: WC2.VerifyContext?)
  
  public var chains: [UInt64] {
    switch self {
    case .v2(let request, _):     return request.payload.chains.compactMap({ chain in
      guard let blockchain = Blockchain(chain) else { return nil }
      return UInt64(blockchain.reference)
    })
    }
  }
  
  public var redirect: String? {
    guard case .v2(let request, _ /*let context*/) = self else { return nil }
    return request.requester.redirect?.native ?? request.requester.redirect?.universal
  }
  
  public func formatAuthMessage(
    address: String, methods: [String] = ["eth_sign", "personal_sign", "eth_signTypedData", "eth_signTypedData_v3", "eth_signTypedData_v4", "eth_signTransaction", "eth_sendTransaction", "wallet_switchEthereumChain"],
    selectedChain: UInt64,
    supportedChains: [UInt64]
  ) throws -> [AuthMessage] {
    var intersection = Array(Set(self.chains).intersection(Set(supportedChains)))
    if intersection.contains(selectedChain) {
      intersection.removeAll(where: { $0 == selectedChain })
      intersection.insert(selectedChain, at: 0)
    }
    guard !intersection.isEmpty else { throw WalletConnectServiceError.badParameters }
    switch self {
    case .v2(let request, _):
      return intersection.compactMap { chain in
        do {
          let payload = try request.formatAuthPayload(account: address, methods: methods, chains: intersection.map({ String($0) }), chain: String(chain))
          let message = try request.formatAuthMessage(payload: payload, account: address, chain: String(chain))
          return AuthMessage(chain: chain, message: message, payload: payload)
        } catch {
          return nil
        }
      }
    }
  }
}

// MARK: - AuthRequest + Equatable

extension AuthRequest: Equatable {}

// MARK: - AuthRequest + Sendable

extension AuthRequest: Sendable {}
