//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/30/23.
//

import Foundation
import mew_wallet_ios_walletconnect_v2

public enum AuthRequest {
  case v2(request: WC2.AuthRequest, context: WC2.VerifyContext?)

  public var chain: UInt64? {
    switch self {
    case .v2(let request, _):     return UInt64(request.payload.chainId)
    }
  }
}

// MARK: - AuthRequest + Equatable

extension AuthRequest: Equatable {}
