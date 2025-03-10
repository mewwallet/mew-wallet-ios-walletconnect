//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/6/23.
//

import os
import Foundation
import mew_wallet_ios_walletconnect_v2

public final class WalletConnectProvider {
  public static let instance = WalletConnectProvider()
  
  public let events = WalletConnectSessionPublisher()
  
  /// Query sessions
  /// - Returns: All sessions
  public var sessions: [Session] {
    return WC2.WalletConnectProvider.instance.sessions
      .map({ .v2(session: $0) })
      .sorted()
  }
  
  // Pairing
  public func pair(url: String?) async throws {
    guard let url else { return }
    do {
      // Try v2
      try await WC2.WalletConnectProvider.instance.pair(url: url)
    } catch WalletConnectServiceError.invalidPairingURL {
      throw WalletConnectServiceError.invalidPairingURL
    } catch {
      Logger.debug(.rootProvider, "Error: \(error)")
    }
  }
  
  public func configure(
    projectId: String,
    groupIdentifier: String,
    notifications: (pushHost: String?, environment: WC2.APNSEnvironment)? = nil,
    metadata: WC2.AppMetadata,
    provider: WC2.CryptoProvider,
    socketFactory: any WC2.WebSocketFactory
  ) {
    // Configure v2
    WC2.WalletConnectProvider.instance.configure(projectId: projectId, groupIdentifier: groupIdentifier, notifications: notifications, metadata: metadata, cryptoProvider: provider, socketFactory: socketFactory)
  }
  
  public func approve<T: Codable & Sendable>(request: Request, result: T) async throws {
    switch request {
    case .v2(let request, _, _):
      try await WC2.WalletConnectProvider.instance.approve(request: request, result: result)
    }
  }
  
  public func reject(request: Request) async throws {
    switch request {
    case .v2(let request, _, _):
      try await WC2.WalletConnectProvider.instance.reject(request: request)
    }
  }
  
  /// For a wallet and a dApp to terminate a session
  ///
  /// Should Error:
  /// - When the session topic is not found
  /// - Parameters:
  ///   - topic: Session that you want to delete
  public func disconnect(session: Session) async throws {
    switch session {
    case .v2(let session):
      try await WC2.WalletConnectProvider.instance.disconnect(session: session)
    }
  }
  
  /// For the wallet to reject a session proposal.
  /// - Parameters:
  ///   - proposalId: Session Proposal id
  ///   - reason: Reason why the session proposal has been rejected. Conforms to CAIP25.
  public func reject(proposal: SessionProposal, reason: RejectionReason) async throws {
    switch proposal {
    case .v2(let proposal, _):
      try await WC2.WalletConnectProvider.instance.reject(proposalId: proposal.id, reason: reason)
    }
  }
  
  public func approve(proposal: SessionProposal, accounts: [String], chains: [UInt64], supportedMethods: Set<String> = []) async throws {
    switch proposal {
    case .v2(let proposal, _):
      try await WC2.WalletConnectProvider.instance.approve(proposal: proposal, chains: chains, accounts: accounts, supportedMethods: supportedMethods)
      
    }
  }
  
  public func update(session: Session, chainId: UInt64?, accounts: [String]) async throws {
    switch session {
    case .v2(let session):
      try await WC2.WalletConnectProvider.instance.update(session: session, chainId: chainId, accounts: accounts)
      break
    }
  }
  
  public func reject(authRequest: AuthRequest) async throws {
    switch authRequest {
    case .v2(let request, _):
      try await WC2.WalletConnectProvider.instance.reject(authRequest: request)
    }
  }
  
  public func approve(authRequest: AuthRequest, signatures: [AuthRequest.SignedAuthMessage], account: String) async throws {
    switch authRequest {
    case .v2(let request, _):
      try await WC2.WalletConnectProvider.instance.approve(
        authRequest: request,
        signatures: signatures.map({ ($0.message.chain, $0.signature, $0.message.payload) }),
        address: account
      )
    }
  }
  
  public func reject(pushRequest: PushRequest) async throws {
    // FIXME: Re-do push notifications
//    switch pushRequest {
//    case .v2(let request):
//      request.reject()
//    }
  }
  
  public func approve(pushRequest: PushRequest, signature: String) async throws {
    // FIXME: Re-do push notifications
//    switch pushRequest {
//    case .v2(let request):
//      request.fulfill(signature)
//    }
  }
  
  public func register(pushToken token: Data) async {
    await WC2.WalletConnectProvider.instance.register(pushToken: token)
  }
  
  public func reset() async {
    await WC2.WalletConnectProvider.instance.reset()
  }
  
  @MainActor public func goBack(uri: String) {
    WC2.WalletConnectProvider.instance.goBack(uri: uri)
  }
  
}
