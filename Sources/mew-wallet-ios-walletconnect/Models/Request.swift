//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import Foundation
import mew_wallet_ios_walletconnect_v1
import mew_wallet_ios_walletconnect_v2
import WalletConnectPairing

public enum Request {
  case v1(request: WC1.Request, session: WC1.Session)
  case v2(request: WC2.Request, context: WC2.VerifyContext?, session: WC2.Session)
  
  public var chain: UInt64? {
    switch self {
    case .v1(_, let session):     return session.chainId
    case .v2(let request, _, _):  return UInt64(request.chainId.reference)
    }
  }
  
  public var redirect: String? {
    guard case .v2(let request, let context, let session) = self else {
      return nil
    }
    return session.peer.redirect?.native ?? session.peer.redirect?.universal
  }
}

// MARK: - Request + Equatable

extension Request: Equatable {}
