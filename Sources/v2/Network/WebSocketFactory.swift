import os
import Starscream
import WalletConnectNetworking
import Foundation
import mew_wallet_ios_logger

struct SocketFactory: WebSocketFactory {
  func create(with url: URL) -> WebSocketConnecting {
    return Socket(url: url)
  }
}

extension SocketFactory {
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
    
    private var _socket: WebSocket
    
    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    var onText: ((String) -> Void)?
    
    init(url: URL) {
      Logger.System.networking.level(.trace)
      self.url = url
      let request = URLRequest(url: url)
      _socket = WebSocket(request: request)
      _socket.callbackQueue = .global(qos: .default)
      _socket.onEvent = {[weak self] event in
        Task {[weak self, event = event] in
          switch event {
          case .connected:        self?._process(status: .connected)
          case .disconnected:     self?._process(status: .disconnected(nil))
          case .error(let error): self?._process(status: .disconnected(error))
          case .cancelled:        self?._process(status: .disconnected(nil))
          case .text(let text):   self?._process(message: text)
          case .ping:             self?._socket.write(pong: Data())
          default:
            Logger.debug(system: .networking, "Event: \(event)")
          }
        }
      }
    }
    
    // MARK: - Private
    
    private func _process(status: SocketConnectionEvent) {
      switch status {
      case .connected:
        guard self.status != .connected else { return }
        self.status = .connected
        Task {[weak self] in
          try? await Task.sleep(nanoseconds: 500_000_000)
          self?.onConnect?()
        }
      case .disconnected(let error):
        guard self.status != .disconnected else { return }
        self.status = .disconnected
        if let error {
          Logger.error(.networking, "Error: \(error)")
        }
        Task {[weak self] in
          self?.onDisconnect?(error)
        }
      }
    }
    
    func _process(message: String) {
      guard message != "text" else {
        _socket.write(pong: Data())
        return
      }
      Task { @MainActor in
        self.onText?(message)
      }
    }
  }
}


extension SocketFactory.Socket: WebSocketConnecting {
  var isConnected: Bool {
    return status == .connected
  }
  
  var request: URLRequest {
    get { _socket.request }
    set(newValue) { _socket.request = newValue }
  }
  
  func connect() {
    guard status == .disconnected else { return }
    status = .connecting
    _socket.connect()
  }
  
  func disconnect() {
    guard status != .disconnected else { return }
    _socket.disconnect()
  }
  
  func write(string: String, completion: (() -> Void)?) {
    _socket.write(string: string, completion: completion)
  }
}
