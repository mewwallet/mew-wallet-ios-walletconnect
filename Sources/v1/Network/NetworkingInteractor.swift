//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import os
import Foundation
import Starscream
import Combine
import mew_wallet_ios_logger

final class NetworkingInteractor {
  enum Status {
    case connected(Session)
    case disconnected(Session)
  }
  
  var connectionStatusPublisher: AnyPublisher<Status, Never> { _connectionStatusSubject.eraseToAnyPublisher() }
  var messagePublisher: AnyPublisher<WCSocketMessage, Never> { _messageSubject.eraseToAnyPublisher() }
  
  private var _sockets = Set<Socket>()
  private let _connectionStatusSubject = PassthroughSubject<Status, Never>()
  private let _messageSubject = PassthroughSubject<WCSocketMessage, Never>()
  
  // MARK: - Public
  
  func connect(_ session: Session) {
    Logger.System.networking.level(.debug)
    
    if let socket = _sockets.first(where: { $0.url == session.bridge }) {
      socket.add(session: session)
    } else {
      let socket = Socket(
        url: session.bridge,
        onConnect: {[weak self] session in
          self?._connectionStatusSubject.send(.connected(session))
        }, onDisconnect: {[weak self] session in
          self?._connectionStatusSubject.send(.disconnected(session))
        }, onMessage: {[weak self] message in
          self?._messageSubject.send(message)
        }
      )
      socket.add(session: session)
      _sockets.insert(socket)
      socket.connect()
    }
  }
    
  func disconnect(session: Session) {
    guard let socket = _sockets.first(where: { $0.url == session.bridge }) else { return }
    let keepAlive = socket.remove(session: session)
    if !keepAlive {
      socket.disconnect()
      _sockets.remove(socket)
    }
  }
  
  func send(message: any Codable, to session: Session) throws {
    guard let socket = _sockets.first(where: { $0.url == session.bridge }) else { return }
    try socket.send(message: message)
  }
}

