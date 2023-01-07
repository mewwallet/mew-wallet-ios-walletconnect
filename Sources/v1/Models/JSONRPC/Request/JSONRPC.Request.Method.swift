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
    case eth_signTypeData(address: String, message: Any)
    case eth_signTransaction(transaction: JSONRPC.Request.Params.Transaction)
    case eth_sendTransaction(transaction: JSONRPC.Request.Params.Transaction)
    
    var _method: _Method {
      switch self {
      case .wc_sessionRequest:    return .wc_sessionRequest
      case .wc_sessionUpdate:     return .wc_sessionUpdate
      case .eth_sign:             return .eth_sign
      case .eth_personalSign:     return .eth_personalSign
      case .eth_signTypeData:     return .eth_signTypeData
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
    case eth_signTypeData     = "eth_signTypedData"
    case eth_signTransaction  = "eth_signTransaction"
    case eth_sendTransaction  = "eth_sendTransaction"
  }
}
