//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import Foundation

extension JSONRPC {
  public struct Request: Codable {
    private enum CodingKeys: CodingKey {
      case id
      case jsonrpc
      case method
      case params
    }
    
    public var id: JSONRPC.ID = .int(Int64(Date().timeIntervalSince1970) * 1000)
    var jsonrpc: String = "2.0"
    public let method: Method
    
    init(method: Method) {
      self.method = method
    }
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.id           = try container.decode(JSONRPC.ID.self, forKey: .id)
      self.jsonrpc      = try container.decode(String.self, forKey: .jsonrpc)
      let method        = try container.decode(JSONRPC.Request._Method.self, forKey: .method)
      switch method {
      case .wc_sessionRequest:
        let params      = try container.decode([JSONRPC.Request.Params.SessionRequest].self, forKey: .params)
        guard let request = params.first else { throw DecodingError.dataCorruptedError(forKey: CodingKeys.params, in: container, debugDescription: "the container contains nothing decodable") }
        self.method = .wc_sessionRequest(request: request)
      
      case .wc_sessionUpdate:
        let params      = try container.decode([JSONRPC.Request.Params.SessionUpdate].self, forKey: .params)
        guard let update = params.first else { throw DecodingError.dataCorruptedError(forKey: CodingKeys.params, in: container, debugDescription: "the container contains nothing decodable") }
        self.method = .wc_sessionUpdate(update: update)
        
      case .eth_personalSign:
        let params      = try container.decode([String].self, forKey: .params)
        guard params.count == 2 else { throw DecodingError.dataCorruptedError(forKey: CodingKeys.params, in: container, debugDescription: "Bad parameters") }
        let messageHex = params[0]
        let address = params[1]
        
        let messageData = Data(hex: messageHex)
        let message = String(data: messageData, encoding: .utf8)
        self.method = .eth_personalSign(address: address, data: messageData, message: message)
        
      case .eth_sign:
        let params      = try container.decode([String].self, forKey: .params)
        guard params.count == 2 else { throw DecodingError.dataCorruptedError(forKey: CodingKeys.params, in: container, debugDescription: "Bad parameters") }
        let messageHex = params[1]
        let address = params[0]
        
        let messageData = Data(hex: messageHex)
        let message = String(data: messageData, encoding: .utf8)
        self.method = .eth_sign(address: address, data: messageData, message: message)
        
      case .eth_signTypeData:
        var params      = try container.nestedUnkeyedContainer(forKey: .params)
        guard params.count == 2 else { throw DecodingError.dataCorruptedError(forKey: CodingKeys.params, in: container, debugDescription: "Bad parameters") }
        
        let address     = try params.decode(String.self)
        let messageJSON = try params.decode(String.self)
        guard let data = messageJSON.data(using: .utf8) else { throw DecodingError.dataCorruptedError(forKey: CodingKeys.params, in: container, debugDescription: "Bad parameters") }
        let message = try JSONSerialization.jsonObject(with: data)
        self.method = .eth_signTypeData(address: address, message: message)
        
      case .eth_sendTransaction:
        let params      = try container.decode([JSONRPC.Request.Params.Transaction].self, forKey: .params)
        guard let transaction = params.first else { throw DecodingError.dataCorruptedError(forKey: CodingKeys.params, in: container, debugDescription: "the container contains nothing decodable") }
        self.method = .eth_sendTransaction(transaction: transaction)
        
      case .eth_signTransaction:
        let params      = try container.decode([JSONRPC.Request.Params.Transaction].self, forKey: .params)
        guard let transaction = params.first else { throw DecodingError.dataCorruptedError(forKey: CodingKeys.params, in: container, debugDescription: "the container contains nothing decodable") }
        self.method = .eth_signTransaction(transaction: transaction)
      }
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(self.id,                                 forKey: .id)
      try container.encode(self.jsonrpc,                            forKey: .jsonrpc)
      try container.encode(self.method._method,                     forKey: .method)
      switch self.method {
      case .wc_sessionRequest(let request):
        try container.encode([request],                             forKey: .params)
      case .wc_sessionUpdate(let update):
        try container.encode([update],                              forKey: .params)
      case .eth_personalSign(let address, let data, _):
        try container.encode(["0x" + data.toHexString(), address],  forKey: .params)
      case .eth_sign(let address, let data, _):
        try container.encode([address, "0x" + data.toHexString()],  forKey: .params)
      case .eth_signTypeData(let address, let message):
        let data = try JSONSerialization.data(withJSONObject: message)
        guard let message = String(data: data, encoding: .utf8) else { throw EncodingError.invalidValue(message, .init(codingPath: [], debugDescription: "Can't encode data")) }
        try container.encode([address, message],                    forKey: .params)
      case .eth_sendTransaction(let transaction):
        try container.encode([transaction],                         forKey: .params)
      case .eth_signTransaction(let transaction):
        try container.encode([transaction],                         forKey: .params)
      }
    }
  }
}
