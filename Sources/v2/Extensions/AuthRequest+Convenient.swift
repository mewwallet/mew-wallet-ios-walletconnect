//
//  File.swift
//  mew-wallet-ios-walletconnect
//
//  Created by Mikhail Nikanorov on 2/20/25.
//

import Foundation
import ReownWalletKit

extension WCAuthRequest {
  public func formatAuthPayload(account: String, methods: [String], chains: [String], chain: String) throws -> WCAuthPayload {
    let blockchains = chains.map { Blockchain(namespace: "eip155", reference: $0)! }
    return try WalletKit.instance.buildAuthPayload(payload: self.payload, supportedEVMChains: blockchains, supportedMethods: methods)
  }
  
  public func formatAuthMessage(payload: WCAuthPayload, account: String, chain: String) throws -> String {
    guard let blockchain = Blockchain(namespace: "eip155", reference: chain),
          let account = Account(blockchain: blockchain, address: account) else {
      throw WalletConnectServiceError.badParameters
    }
    
    return try WalletKit.instance.formatAuthMessage(payload: payload, account: account)
  }
}
