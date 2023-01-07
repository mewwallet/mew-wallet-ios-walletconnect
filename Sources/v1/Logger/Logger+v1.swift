//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import os
import Foundation
import mew_wallet_ios_logger

extension Logger.System {
  public static var sessionManager = Logger.System.with(subsystem: "com.myetherwallet.mewwallet.walletconnect.v1", category: "session manager")
  public static var networking     = Logger.System.with(subsystem: "com.myetherwallet.mewwallet.walletconnect.v1", category: "networking")
  public static var provider       = Logger.System.with(subsystem: "com.myetherwallet.mewwallet.walletconnect.v1", category: "provider")
}
