//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/6/23.
//

import os
import Foundation
import Starscream
import mew_wallet_ios_logger

extension NetworkingInteractor {
  final class Socket {
    enum ConnectionStatus {
      case disconnected
      case connecting
      case connected
    }
    
    enum SocketConnectionEvent {
      case connected
      case disconnected(_ error: Error?)
    }
    
    var status: ConnectionStatus = .disconnected {
      didSet {
        switch status {
        case .disconnected:
          Logger.debug(.networking, "[disconnected]: \(url)")
        case .connecting:
          Logger.debug(.networking, "[connecting]: \(url)")
        case .connected:
          Logger.debug(.networking, "[connected]: \(url)")
        }
      }
    }
    let url: URL
    
    private var _socket: WebSocket?
    private var _pending = Set<Session>()
    private var _sessions = Set<Session>()
    
    private var onConnect: (Session) -> Void
    private var onDisconnect: (Session) -> Void
    private var onMessage: (WCSocketMessage) -> Void
    
    init(url: URL, onConnect: @escaping (Session) -> Void, onDisconnect: @escaping (Session) -> Void, onMessage: @escaping (WCSocketMessage) -> Void) {
      self.url = url
      self.onConnect = onConnect
      self.onDisconnect = onDisconnect
      self.onMessage = onMessage
    }
    
    func add(session: Session) {
      guard self.status != .connected else {
        onConnect(session)
        return
      }
      Logger.debug(.networking, ">> new pending session: \(session.topic)")
      _pending.insert(session)
    }
    
    func remove(session: Session) -> Bool /*Keep alive*/ {
      Logger.debug(.networking, "<> kill session: \(session.topic)")
      _sessions.remove(session)
      _pending.remove(session)
      return !_sessions.isEmpty || !_pending.isEmpty
    }
    
    func connect() {
      guard _socket == nil else {
        if status == .disconnected {
          status = .connecting
          _socket?.connect()
        }
        return
      }
      var request = URLRequest(url: url)
      request.timeoutInterval = 20
      _socket = WebSocket(request: request)
      
      _socket?.onEvent = {[weak self, weak _socket] event in
        Logger.debug(.networking, "event: \(event)")
        guard let socket = _socket else { return }
        switch event {
        case .connected:        self?._process(socket: socket, status: .connected)
        case .disconnected:     self?._process(socket: socket, status: .disconnected(nil))
        case .error(let error): self?._process(socket: socket, status: .disconnected(error))
        case .cancelled:        self?._process(socket: socket, status: .disconnected(nil))
        case .text(let text):   self?._process(socket: socket, message: text)
        case .ping:             socket.write(pong: Data())
        default:
          debugPrint(event)
        }
      }
      status = .connecting
      _socket?.connect()
    }
    
    func disconnect() {
      guard self.status != .disconnected else { return }
      Logger.debug(.networking, "<> disconnect: \(url)")
      status = .disconnected
      _socket?.disconnect(closeCode: CloseCode.goingAway.rawValue)
    }
    
    func send(message: any Codable) throws {
      let data = try JSONEncoder().encode(message)
      _socket?.write(data: data)
      Logger.debug(.networking, ">> message sent: \(url)")
    }
    
    // MARK: - Private
    
    private func _process(socket: WebSocket, status: SocketConnectionEvent) {
      switch status {
      case .connected:
        self.status = .connected
        _pending.forEach {
          self.onConnect($0)
          _sessions.insert($0)
        }
        _pending.removeAll()
      case .disconnected(let error):
        self.status = .disconnected
        if let error {
          Logger.error(.networking, error)
        }
        _sessions.forEach {
          self.onDisconnect($0)
          _pending.insert($0)
        }
        _sessions.removeAll()
        Task {[weak self] in
          try await Task.sleep(nanoseconds: 3_000_000_000)
          self?.connect()
        }
      }
    }
    
    func _process(socket: WebSocket, message: String) {
      guard message != "text" else {
        socket.write(pong: Data())
        return
      }
      
      Logger.debug(.networking, "<< new incoming message")
      
      guard let data = message.data(using: .utf8) else { return }
      
      do {
        let decoder = JSONDecoder()
        let message = try decoder.decode(WCSocketMessage.self, from: data)
        self.onMessage(message)
      } catch {
        Logger.error(.networking, "Error: \(error)")
      }
    }
  }
}

extension NetworkingInteractor.Socket: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(self.url)
  }
}

extension NetworkingInteractor.Socket: Equatable {
  static func == (lhs: NetworkingInteractor.Socket, rhs: NetworkingInteractor.Socket) -> Bool {
    return lhs.url == rhs.url
  }
}
