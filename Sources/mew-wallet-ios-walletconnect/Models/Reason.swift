//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import Foundation
import mew_wallet_ios_walletconnect_v2

public enum Reason {
  case v2(reason: any WC2.Reason)
}

// MARK: - Reason + Sendable

extension Reason: Sendable {}
