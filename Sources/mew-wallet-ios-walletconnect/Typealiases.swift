//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/6/23.
//

import Foundation
import mew_wallet_ios_walletconnect_v2

public struct WC2 {
  public typealias WalletConnectProvider = mew_wallet_ios_walletconnect_v2.WalletConnectProvider
  public typealias AppMetadata = mew_wallet_ios_walletconnect_v2.AppMetadata
  public typealias Session = mew_wallet_ios_walletconnect_v2.Session
  public typealias VerifyContext = mew_wallet_ios_walletconnect_v2.VerifyContext
  public typealias Request = mew_wallet_ios_walletconnect_v2.Request
  public typealias AuthRequest = mew_wallet_ios_walletconnect_v2.WCAuthRequest
  public typealias Reason = mew_wallet_ios_walletconnect_v2.Reason
  public typealias CryptoProvider = mew_wallet_ios_walletconnect_v2.WCCryptoProvider & mew_wallet_ios_walletconnect_v2.WCBIP44Provider
  public typealias SIWECacaoFormatter = mew_wallet_ios_walletconnect_v2.SIWECacaoFormatter
  public typealias APNSEnvironment = mew_wallet_ios_walletconnect_v2.APNSEnvironment
  public typealias PushOnSignRequest = PushOnSign
  public typealias WebSocketFactory = mew_wallet_ios_walletconnect_v2.WebSocketFactory
  public typealias WebSocketConnecting = mew_wallet_ios_walletconnect_v2.WebSocketConnecting
}
