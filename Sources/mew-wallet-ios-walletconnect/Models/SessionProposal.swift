//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import Foundation
import mew_wallet_ios_walletconnect_v1
import mew_wallet_ios_walletconnect_v2

public enum SessionProposal {
  case v1(request: WC1.Request, session: WC1.Session)
  case v2(proposal: WC2.Session.Proposal)
  
  public var chainIds: [UInt64]? {
    switch self {
    case .v1(_, let session):
      return [session.chainId]
    case .v2(let proposal):
      guard !proposal.requiredNamespaces.contains(where: { $0.key != "eip155" }) else { return nil }
      let chainIdsReferences = proposal.requiredNamespaces.flatMap { (_, namespace) in
        namespace.chains.map({ $0.reference })
      }
      let chainIds = chainIdsReferences.compactMap { UInt64($0, radix: 10) }
      guard chainIdsReferences.count == chainIds.count else { return nil }
      return chainIds
    }
  }
}

// MARK: - SessionProposal + Equatable

extension SessionProposal: Equatable {}
