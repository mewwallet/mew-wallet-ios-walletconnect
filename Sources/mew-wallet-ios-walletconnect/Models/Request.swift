//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import Foundation
import mew_wallet_ios_walletconnect_v1
import mew_wallet_ios_walletconnect_v2

public enum Request {
  case v1(request: WC1.Request, session: WC1.Session)
  case v2(request: WC2.Request)
}
