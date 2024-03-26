//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import Foundation
@preconcurrency import WalletConnectSign

private let _nonHexCharacterSet = CharacterSet(charactersIn: "0123456789ABCDEF").inverted

extension Request {
  public var wcMethod: Method {
    do {
      switch method {
      case "eth_sign":
        let params = try self.params.get([String].self)
        guard params.count == 2 else {
          return .raw(method: method, params: self.params.stringRepresentation)
        }
        let messageHex = params[1]
        var address = params[0]
        guard address.count >= 42 else {
          return .raw(method: method, params: self.params.stringRepresentation)
        }
        address = String(address.suffix(42))
        
        let messageData = Data(hex: messageHex)
        let message = String(data: messageData, encoding: .utf8)
        return .eth_sign(address: address, data: messageData, message: message)
        
      case "personal_sign":
        let params = try self.params.get([String].self)
        guard params.count >= 2 else {
          return .raw(method: method, params: self.params.stringRepresentation)
        }
        // Get address
        var address = params[1]
        guard address.count >= 42 else {
          return .raw(method: method, params: self.params.stringRepresentation)
        }
        address = String(address.suffix(42))
        
        // Check message
        var checkMessage = params[0]
        if checkMessage.hasPrefix("0x") {
          let indexStart = checkMessage.index(checkMessage.startIndex, offsetBy: 2)
          checkMessage = String(checkMessage[indexStart...])
        }
        if checkMessage.uppercased().rangeOfCharacter(from: _nonHexCharacterSet) == nil {
          // hex message
          let messageData = Data(hex: checkMessage)
          let message = String(data: messageData, encoding: .utf8)
          return .eth_personalSign(address: address, data: messageData, message: message)
        } else {
          // non-hex message
          let message = params[0]
          guard let messageData = message.data(using: .utf8) else {
            return .raw(method: method, params: self.params.stringRepresentation)
          }
          return .eth_personalSign(address: address, data: messageData, message: message)
        }
        
      case "eth_signTypedData", "eth_signTypedData_v4":
        let params = try self.params.get([String].self)
        guard params.count == 2 else {
          return .raw(method: method, params: self.params.stringRepresentation)
        }
        var address = params[0]
        guard address.count >= 42 else {
          return .raw(method: method, params: self.params.stringRepresentation)
        }
        address = String(address.suffix(42))
        
        let messageJSON = params[1]
        guard let data = messageJSON.data(using: .utf8) else {
          return .raw(method: method, params: self.params.stringRepresentation)
        }
        guard let message = try JSONSerialization.jsonObject(with: data) as? AnyHashable else {
          return .raw(method: method, params: self.params.stringRepresentation)
        }
        return .eth_signTypedData (address: address, message: message)
        
      case "eth_signTransaction":
        let params = try self.params.get([Request.Params.Transaction].self)
        guard params.count == 1 else {
          return .raw(method: method, params: self.params.stringRepresentation)
        }
        let transaction = params[0]
        return .eth_signTransaction(transaction: transaction)
        
      case "eth_sendTransaction":
        let params = try self.params.get([Request.Params.Transaction].self)
        guard params.count == 1 else {
          return .raw(method: method, params: self.params.stringRepresentation)
        }
        let transaction = params[0]
        return .eth_sendTransaction(transaction: transaction)
        
      case "wallet_switchEthereumChain":
        let params = try self.params.get([Request.Params.ChainID].self)
        guard params.count == 1 else {
          return .raw(method: method, params: self.params.stringRepresentation)
        }
        let chain = params[0]
        return .wallet_switchEthereumChain(chain: chain)
        
      default:
        return .raw(method: method, params: self.params.stringRepresentation)
      }
    } catch {
      return .raw(method: method, params: self.params.stringRepresentation)
    }
  }
}
