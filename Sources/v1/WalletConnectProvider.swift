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
  
  public var requestPublisher: AnyPublisher<(Session, JSONRPC.Request), Never> { manager.requestPublisher }
  
  private let manager = SessionManager()
  
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
  public func pair(url: String?) async throws {
    guard let url else { return }
    let wcURL = try WalletConnectURI(string: url)
    try manager.add(wcURL)
  }
  
  public func approve<T: Codable>(request: JSONRPC.Request, for session: Session, result: T) throws {
    switch request.method {
    case .wc_sessionRequest:
      guard let result = result as? [String] else { throw WalletConnectProvider.Error.badResult }
      let approve = JSONRPC.ApproveSession(
        approved: true,
        chainId: 1,
        accounts: result,
        peerId: session.uuid,
        peerMeta: self.metadata
      )
      let response = JSONRPC.Response(id: request.id, result: approve)
      do {
        try manager.send(message: response, for: session)
      } catch {
        Logger.error(.provider, "\(error)")
      }
    default:
      let response = JSONRPC.Response(id: request.id, result: result)
      do {
        try manager.send(message: response, for: session)
      } catch {
        Logger.error(.provider, "\(error)")
      }
    }
  }
  
  public func reject(request: JSONRPC.Request, for session: Session) {
    let response = JSONRPC.Response<Int>(id: request.id, error: .rejected)
    do {
      try manager.send(message: response, for: session)
    } catch {
      Logger.error(.provider, error)
    }
  }
  
  public func disconnect(session: Session) {
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

