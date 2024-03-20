//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/20/23.
//

import os
import Foundation
import mew_wallet_ios_logger

extension Logger.System {
  public static let rootProvider       = Logger.System.with(subsystem: "com.myetherwallet.mewwallet.walletconnect", category: "root: provider")
}
