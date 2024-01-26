//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import Foundation
import WalletConnectSign
import mew_wallet_ios_walletconnect_v1
import mew_wallet_ios_walletconnect_v2

public enum SessionProposal {
  case v1(request: WC1.Request, session: WC1.Session)
  case v2(proposal: WC2.Session.Proposal, context: WC2.VerifyContext?)
  
  public var chainIds: [UInt64]? {
    switch self {
    case .v1(_, let session):
      return [session.chainId]
    case .v2(let proposal, _):
      guard !proposal.requiredNamespaces.contains(where: { !$0.key.hasPrefix("eip155") }) else { return nil }
      let chainIdsReferences = proposal.requiredNamespaces.flatMap { (key, namespace) -> [String] in
        if let chains = namespace.chains {
          return chains.map({ $0.reference })
        } else if key.count > 7 {
          var chainId = key
          chainId.removeFirst(7)
          guard !chainId.isEmpty else { return [] }
          return [chainId]
        } else {
          return []
        }
      }
      let chainIds = chainIdsReferences.compactMap { UInt64($0, radix: 10) }
      guard chainIdsReferences.count == chainIds.count else { return nil }
      return chainIds
    }
  }
  
  public var optionalChainIds: [UInt64]? {
    switch self {
    case .v1:
      return nil
    case .v2(let proposal, _):
      guard let namespace = proposal.optionalNamespaces else { return nil }
      guard !namespace.contains(where: { !$0.key.hasPrefix("eip155") }) else { return nil }
      let chainIdsReferences = namespace.flatMap { (key, namespace) -> [String] in
        if let chains = namespace.chains {
          return chains.map({ $0.reference })
        } else if key.count > 7 {
          var chainId = key
          chainId.removeFirst(7)
          guard !chainId.isEmpty else { return [] }
          return [chainId]
        } else {
          return []
        }
      }
      let chainIds = chainIdsReferences.compactMap { UInt64($0, radix: 10) }
      guard chainIdsReferences.count == chainIds.count else { return nil }
      return chainIds
    }
  }
  
  public var redirect: String? {
    guard case .v2(let proposal, let context) = self else {
      return nil
    }
    return proposal.proposer.redirect?.native ?? proposal.proposer.redirect?.universal
  }
}

// MARK: - SessionProposal + Equatable

extension SessionProposal: Equatable {}
