//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import Foundation

extension JSONRPC.Request {
  public enum Method {
    case wc_sessionRequest(request: JSONRPC.Request.Params.SessionRequest)
    case wc_sessionUpdate(update: JSONRPC.Request.Params.SessionUpdate)

    case eth_sign(address: String, data: Data, message: String?)
    case eth_personalSign(address: String, data: Data, message: String?)
    case eth_signTypedData(address: String, message: AnyHashable)
    case eth_signTransaction(transaction: JSONRPC.Request.Params.Transaction)
    case eth_sendTransaction(transaction: JSONRPC.Request.Params.Transaction)
    
    var _method: _Method {
      switch self {
      case .wc_sessionRequest:    return .wc_sessionRequest
      case .wc_sessionUpdate:     return .wc_sessionUpdate
      case .eth_sign:             return .eth_sign
      case .eth_personalSign:     return .eth_personalSign
      case .eth_signTypedData:    return .eth_signTypedData
      case .eth_signTransaction:  return .eth_signTransaction
      case .eth_sendTransaction:  return .eth_sendTransaction
      }
    }
  }
  
  enum _Method: String, Codable {
    case wc_sessionRequest    = "wc_sessionRequest"
    case wc_sessionUpdate     = "wc_sessionUpdate"
    case eth_sign             = "eth_sign"
    case eth_personalSign     = "personal_sign"
    case eth_signTypedData    = "eth_signTypedData"
    case eth_signTransaction  = "eth_signTransaction"
    case eth_sendTransaction  = "eth_sendTransaction"
  }
}

// MARK: - JSONRPC.Request.Method + Equatable

extension JSONRPC.Request.Method: Equatable {
  public static func == (lhs: JSONRPC.Request.Method, rhs: JSONRPC.Request.Method) -> Bool {
    guard lhs._method == rhs._method else { return false }
    switch (lhs, rhs) {
    case (.wc_sessionRequest(let lhsRequest), .wc_sessionRequest(let rhsRequest)):
      return lhsRequest == rhsRequest
    case (.wc_sessionUpdate(let lhsUpdate), .wc_sessionUpdate(let rhsUpdate)):
      return lhsUpdate == rhsUpdate
    case (.eth_sign(let lhsAddress, let lhsData, let lhsMessage), .eth_sign(let rhsAddress, let rhsData, let rhsMessage)):
      return lhsAddress == rhsAddress && lhsData == rhsData && lhsMessage == rhsMessage
    case (.eth_personalSign(let lhsAddress, let lhsData, let lhsMessage), .eth_personalSign(let rhsAddress, let rhsData, let rhsMessage)):
      return lhsAddress == rhsAddress && lhsData == rhsData && lhsMessage == rhsMessage
    case (.eth_signTypedData(let lhsAddress, let lhsMessage), .eth_signTypedData(let rhsAddress, let rhsMessage)):
      return lhsAddress == rhsAddress && lhsMessage == rhsMessage
    case (.eth_signTransaction(let lhsTransaction), .eth_signTransaction(let rhsTransaction)):
      return lhsTransaction == rhsTransaction
    case (.eth_sendTransaction(let lhsTransaction), .eth_sendTransaction(let rhsTransaction)):
      return lhsTransaction == rhsTransaction
    default:
      return false
    }
  }
}
