//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import Foundation
import Combine

public final class WalletConnectSessionPublisher {
  /// Your Wallet should allow users to scan a QR code generated by dapps. You are responsible for implementing it on your own. For testing, you can use our test dapp at: https://react-app.walletconnect.com/, which is v2 protocol compliant. Once you derive a URI from the QR code call pair method: try await WallectConnectServiceImpl.instance.pair(uri: uri)
  /// if everything goes well, you should handle following event:
  public var sessionProposal: AnyPublisher<(JSONRPC.Request, Session), Never> {
    return WalletConnectProvider.instance.manager.sessionProposalPublisher
  }

  
  /// After the session is established, a dapp will request your wallet's users to sign a transaction or a message. Requests will be delivered by the following publisher:
  public var sessionRequest: AnyPublisher<(JSONRPC.Request, Session), Never> {
    return WalletConnectProvider.instance.manager.requestPublisher
  }
  
  public var sessionDelete: AnyPublisher<(String, Reason), Never> {
    return WalletConnectProvider.instance.manager.sessionDeletePublisher
  }
}
