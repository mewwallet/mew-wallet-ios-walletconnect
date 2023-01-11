//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/6/23.
//

import Foundation
import mew_wallet_ios_walletconnect_v1
import mew_wallet_ios_walletconnect_v2

public final class WalletConnectProvider {
  public static let instance = WalletConnectProvider()
  
  public let events = WalletConnectSessionPublisher()
  
  /// Query sessions
  /// - Returns: All sessions
  public var sessions: [Session] {
    let v1: [Session] = WC1.WalletConnectProvider.instance.sessions
      .map({ .v1(session: $0) })
    
    let v2: [Session] = WC2.WalletConnectProvider.instance.sessions
      .map({ .v2(session: $0) })
    
    return (v1 + v2).sorted()
  }
  
  // Pairing
  public func pair(url: String?) async throws {
    guard let url else { return }
    do {
      // Try v2 first
      try await WC2.WalletConnectProvider.instance.pair(url: url)
    } catch WalletConnectServiceError.invalidPairingURL {
      do {
        // If fails - try v1
        try await WC1.WalletConnectProvider.instance.pair(url: url)
      } catch {
        throw error
      }
    } catch {
      debugPrint("error: \(error)")
    }
  }
  
  public func configure(projectId: String, metadata: WC2.AppMetadata, storage: WC1.SessionStorage) {
    // Configure v2
    WC2.WalletConnectProvider.instance.configure(projectId: projectId, metadata: metadata)
    // Configure v1
    let metadata = WC1.Session.AppMetadata(name: metadata.name, url: metadata.url, description: metadata.description, icons: metadata.icons)
    WC1.WalletConnectProvider.instance.configure(metadata: metadata, storage: storage)
  }
  
  public func approve<T: Codable>(request: Request, result: T) async throws {
    switch request {
    case .v1(let request, let session):
      try await WC1.WalletConnectProvider.instance.approve(request: request, for: session, result: result)
    case .v2(let request):
      try await WC2.WalletConnectProvider.instance.approve(request: request, result: result)
    }
  }
  
  public func reject(request: Request) async throws {
    switch request {
    case .v1(let request, let session):
      try await WC1.WalletConnectProvider.instance.reject(request: request, for: session)
    case .v2(let request):
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
    case .v1(let session):
      try await WC1.WalletConnectProvider.instance.disconnect(session: session)
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
    case .v1(let request, let session):
      try await WC1.WalletConnectProvider.instance.reject(request: request, for: session)
    case .v2(let proposal):
      try await WC2.WalletConnectProvider.instance.reject(proposalId: proposal.id, reason: reason)
    }
  }
  
  public func approve(proposal: SessionProposal, accounts: [String]) async throws {
    switch proposal {
    case .v1(let request, let session):
      try await WC1.WalletConnectProvider.instance.approve(request: request, for: session, result: accounts)
    case .v2(let proposal):
      try await WC2.WalletConnectProvider.instance.approve(proposal: proposal, accounts: accounts)
      
    }
  }
  
}
