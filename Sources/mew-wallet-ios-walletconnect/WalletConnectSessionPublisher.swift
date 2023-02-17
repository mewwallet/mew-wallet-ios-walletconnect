//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import Foundation
import Combine
import mew_wallet_ios_walletconnect_v1
import mew_wallet_ios_walletconnect_v2

public final class WalletConnectSessionPublisher {
  /// Your Wallet should allow users to scan a QR code generated by dapps. You are responsible for implementing it on your own. For testing, you can use our test dapp at: https://react-app.walletconnect.com/, which is v2 protocol compliant. Once you derive a URI from the QR code call pair method: try await WallectConnectServiceImpl.instance.pair(uri: uri)
  /// if everything goes well, you should handle following event:
  public var sessionProposal: AnyPublisher<SessionProposal, Never> {
    let v1 = WC1.WalletConnectProvider.instance.events.sessionProposal
      .map { SessionProposal.v1(request: $0, session: $1) }
    
    let v2 = WC2.WalletConnectProvider.instance.events.sessionProposal
      .map { SessionProposal.v2(proposal: $0) }
    
    return Publishers.Merge(v1, v2)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  /// After the session is established, a dapp will request your wallet's users to sign a transaction or a message. Requests will be delivered by the following publisher:
  public var sessionRequest: AnyPublisher<Request, Never> {
    let v1 = WC1.WalletConnectProvider.instance.events.sessionRequest
      .map { Request.v1(request: $0, session: $1) }
    
    let v2 = WC2.WalletConnectProvider.instance.events.sessionRequest
      .compactMap { request -> Request? in
        guard let session = WC2.WalletConnectProvider.instance.sessions.first(where: { $0.topic == request.topic }) else { return nil }
        return Request.v2(request: request, session: session)
      }
    
    return Publishers.Merge(v1, v2)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  public var sessionDelete: AnyPublisher<(String, Reason), Never> {
    let v1 = WC1.WalletConnectProvider.instance.events.sessionDelete
      .map { ($0, Reason.v1(reason: $1)) }
    
    let v2 = WC2.WalletConnectProvider.instance.events.sessionDelete
      .map { ($0, Reason.v2(reason: $1)) }
    
    return Publishers.Merge(v1, v2)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  public var sessionsUpdate: AnyPublisher<Void, Never> {
    let v1 = WC1.WalletConnectProvider.instance.events.sessionsUpdate
    
    let v2 = Publishers.Merge4(
      WC2.WalletConnectProvider.instance.events.sessionProposal.map { _ in },
      WC2.WalletConnectProvider.instance.events.sessionSettle.map { _ in },
      WC2.WalletConnectProvider.instance.events.sessionDelete.map { _ in },
      WC2.WalletConnectProvider.instance.events.sessionUpdate.map { _ in }
    )
    
    return Publishers.Merge(v1, v2)
      .map { _ in }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}
