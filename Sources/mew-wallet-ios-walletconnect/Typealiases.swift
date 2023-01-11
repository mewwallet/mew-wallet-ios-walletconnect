//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/6/23.
//

import Foundation
import mew_wallet_ios_walletconnect_v1
import mew_wallet_ios_walletconnect_v2

public struct WC1 {
  public typealias WalletConnectProvider = mew_wallet_ios_walletconnect_v1.WalletConnectProvider
  public typealias SessionStorage = mew_wallet_ios_walletconnect_v1.SessionStorage
  public typealias Session = mew_wallet_ios_walletconnect_v1.Session
  public typealias Request = mew_wallet_ios_walletconnect_v1.JSONRPC.Request
  public typealias Reason = mew_wallet_ios_walletconnect_v1.Reason
}

public struct WC2 {
  public typealias WalletConnectProvider = mew_wallet_ios_walletconnect_v2.WalletConnectProvider
  public typealias AppMetadata = mew_wallet_ios_walletconnect_v2.AppMetadata
  public typealias Session = mew_wallet_ios_walletconnect_v2.Session
  public typealias Request = mew_wallet_ios_walletconnect_v2.Request
  public typealias Reason = mew_wallet_ios_walletconnect_v2.Reason
}
