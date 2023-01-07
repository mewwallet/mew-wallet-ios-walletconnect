import Starscream
import WalletConnectNetworking
import Foundation

struct SocketFactory: WebSocketFactory {
  func create(with url: URL) -> WebSocketConnecting {

    return WalletConnectSocket(url: url)
  }
}

final class WalletConnectSocket {
  private let socket: Starscream.WebSocket
  
  var onConnect: (() -> Void)?
  var onDisconnect: ((Error?) -> Void)?
  var onText: ((String) -> Void)?
  var isConnected = false
  
  init(url: URL) {
    let request = URLRequest(url: url)
    socket = WebSocket(request: request)
    socket.delegate = self
  }
}

extension WalletConnectSocket: WebSocketConnecting {
  var request: URLRequest {
    get {
      socket.request
    }
    set(newValue) {
      socket.request = newValue
    }
  }
  
  func connect() {
    socket.connect()
  }
  
  func disconnect() {
    socket.disconnect()
  }
  
  func write(string: String, completion: (() -> Void)?) {
    socket.write(string: string, completion: completion)
  }
}

extension WalletConnectSocket: WebSocketDelegate {
  func didReceive(event: WebSocketEvent, client: WebSocket) {
    switch event {
    case .text(let text):
      onText?(text)
    case .connected:
      isConnected = true
      onConnect?()
    case .disconnected:
      isConnected = false
      onDisconnect?(nil)
    default:
      break
    }
  }
}
