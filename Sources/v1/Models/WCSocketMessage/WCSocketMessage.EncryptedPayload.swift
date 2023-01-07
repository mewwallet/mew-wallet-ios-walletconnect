//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/6/23.
//

import Foundation

private extension CodingUserInfoKey {
  static var wrapOrUnwrap: CodingUserInfoKey {
    return CodingUserInfoKey(rawValue: "wrapOrUnwrap")!
  }
}

extension WCSocketMessage {
  struct EncrypedPayload: Codable {
    private enum CodingKeys: CodingKey {
      case data
      case hmac
      case iv
    }
    
    public let data: String
    public let hmac: String
    public let iv: String
    
    public init(data: String, hmac: String, iv: String) {
      self.data = data
      self.hmac = hmac
      self.iv = iv
    }
    
    init(from decoder: Decoder) throws {
      if decoder.userInfo[.wrapOrUnwrap] == nil {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let data = string.data(using: .utf8) else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing decodable") }
        let decoder = JSONDecoder()
        decoder.userInfo[.wrapOrUnwrap] = true
        self = try decoder.decode(Self.self, from: data)
      } else {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode(String.self,   forKey: .data)
        self.hmac = try container.decode(String.self,   forKey: .hmac)
        self.iv = try container.decode(String.self,     forKey: .iv)
      }
    }
    
    func encode(to encoder: Encoder) throws {
      if encoder.userInfo[.wrapOrUnwrap] != nil {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.data,                 forKey: .data)
        try container.encode(self.hmac,                 forKey: .hmac)
        try container.encode(self.iv,                   forKey: .iv)
      } else {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.userInfo[.wrapOrUnwrap] = true
        let data = try jsonEncoder.encode(self)
        guard let string = String(data: data, encoding: .utf8) else { throw EncodingError.invalidValue(data, .init(codingPath: [], debugDescription: "Can't encode data")) }
        var container = encoder.singleValueContainer()
        try container.encode(string)
      }
    }
  }
}
