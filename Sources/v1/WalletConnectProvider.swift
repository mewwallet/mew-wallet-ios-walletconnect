//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import os
import Foundation
import Combine
import mew_wallet_ios_logger

public final class WalletConnectProvider {
  public static let instance = WalletConnectProvider()
  
  private var metadata: Session.AppMetadata?
  
  internal let manager = SessionManager()
  
  public let events = WalletConnectSessionPublisher()
  
  /// Query sessions
  /// - Returns: All sessions
  public var sessions: [Session] {
    return manager.storage.sessions
  }
  
  public func configure(metadata: Session.AppMetadata, storage: SessionStorage) {
    self.metadata = metadata
    manager.configure(storage: storage)
  }
  
  /// For wallet to establish a pairing
  /// Wallet should call this function in order to accept peer's pairing proposal and be able to subscribe for future requests.
  /// - Parameter uri: Pairing URI that is commonly presented as a QR code by a dapp or delivered with universal linking.
  ///
  /// Throws Error:
  /// - When URI is invalid format or missing params
  /// - When topic is already in use
  public func pair(url: String) async throws {
    let wcURL = try WalletConnectURI(string: url)
    try manager.add(wcURL)
  }
  
  public func cancelPair(url: String) async throws {
    let wcURL = try WalletConnectURI(string: url)
    try manager.cancel(wcURL)
  }
  
  // TODO: ChainID is here!
  public func approve<T: Codable>(request: JSONRPC.Request, for session: Session, result: T) async throws {
    switch request.method {
    case .wc_sessionRequest:
      throw WalletConnectProvider.Error.badRequest
    default:
      let response = JSONRPC.Response(id: request.id, result: result)
      do {
        try manager.send(message: response, for: session)
      } catch {
        Logger.error(.provider, "\(error)")
      }
    }
  }
  
  public func approve<T: Codable>(proposal: JSONRPC.Request, for session: Session, result: T, chainId: UInt64) async throws {
    guard case .wc_sessionRequest = proposal.method else { throw WalletConnectProvider.Error.badResult }
    guard let result = result as? [String] else { throw WalletConnectProvider.Error.badResult }
    let approve = JSONRPC.ApproveSession(
      approved: true,
      chainId: chainId,
      accounts: result,
      peerId: session.uuid,
      peerMeta: self.metadata
    )
    let response = JSONRPC.Response(id: proposal.id, result: approve)
    do {
      try manager.send(message: response, for: session)
      session.update(with: approve)
      manager.update(session: session)
    } catch {
      Logger.error(.provider, "\(error)")
    }
  }
  
  public func reject(proposal: JSONRPC.Request, for session: Session) async throws {
    let response = JSONRPC.Response<Int>(id: proposal.id, error: .rejected)
    do {
      try manager.send(message: response, for: session)
      manager.disconnect(session: session)
    } catch {
      Logger.error(.provider, error)
    }
  }
  
  public func reject(request: JSONRPC.Request, for session: Session) async throws {
    let response = JSONRPC.Response<Int>(id: request.id, error: .rejected)
    do {
      try manager.send(message: response, for: session)
    } catch {
      Logger.error(.provider, error)
    }
  }
  
  public func update(session: Session, chainId: UInt64?, accounts: [String]) async throws {
    let update = JSONRPC.Request.Params.SessionUpdate(approved: true,
                                                      chainId: chainId ?? session.chainId,
                                                      accounts: accounts.isEmpty ? session.accounts : accounts)
    let request = JSONRPC.Request(method: .wc_sessionUpdate(update: update))
    do {
      try manager.send(message: request, for: session)
      session.update(with: update)
      manager.update(session: session)
    } catch {
      Logger.error(.provider, error)
    }
  }
  
  public func disconnect(session: Session) async throws {
    let update = JSONRPC.Request.Params.SessionUpdate(
      approved: false,
      chainId: nil,
      accounts: nil
    )
    
    let request = JSONRPC.Request(method: .wc_sessionUpdate(update: update))
    do {
      try manager.send(message: request, for: session)
      manager.disconnect(session: session)
    } catch {
      Logger.error(.provider, error)
    }
  }
}

//{
//  "bridge": "https://7.bridge.walletconnect.org/subscribe",
//  "token": "c393da0919d676196518ea2af91139ceac192326aee059bf91d7886f5981ce12",
//  "platform": "IOS",
//  "topic": "6F64CF9F-C634-4E03-ABB1-3F2278CDDFE8",
//  "language": "en_US"
//}
