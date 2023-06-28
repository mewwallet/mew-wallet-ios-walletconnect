//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/14/23.
//

import Foundation
import mew_wallet_ios_walletconnect_v2

public enum PushRequest {
  case v2(request: WC2.PushOnSignRequest)
}

// MARK: - PushRequest + Equatable

extension PushRequest: Equatable {}
