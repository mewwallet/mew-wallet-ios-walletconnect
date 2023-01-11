//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import os
import Foundation
import mew_wallet_ios_logger

extension Logger.System {
  public static var networking     = Logger.System.with(subsystem: "com.myetherwallet.mewwallet.walletconnect.v2", category: "v2: networking")
}
