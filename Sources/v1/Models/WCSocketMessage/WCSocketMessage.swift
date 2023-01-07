//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import Foundation
import CryptoSwift

struct WCSocketMessage: Codable {
  enum MessageType: String, Codable {
    case pub
    case sub
  }
  public let topic: String
  public let type: MessageType
  public let payload: EncrypedPayload?
  public let silent: Bool?
  
  init(topic: String, type: MessageType, payload: EncrypedPayload? = nil, silent: Bool? = nil) {
    self.topic = topic
    self.type = type
    self.payload = payload
    self.silent = silent
  }
  
  init(from decoder: Decoder) throws {
    let container: KeyedDecodingContainer<WCSocketMessage.CodingKeys> = try decoder.container(keyedBy: WCSocketMessage.CodingKeys.self)
    self.topic    = try container.decode(String.self,                       forKey: .topic)
    self.type     = try container.decode(WCSocketMessage.MessageType.self,  forKey: .type)
    self.silent   = try container.decodeIfPresent(Bool.self,                forKey: .silent)
    self.payload  = try container.decode(EncrypedPayload.self,              forKey: .payload)
  }
  
  enum CodingKeys: CodingKey {
    case topic
    case type
    case payload
    case silent
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.topic,            forKey: .topic)
    try container.encode(self.type,             forKey: .type)
    if let payload {
      try container.encode(payload,             forKey: .payload)
    } else {
      try container.encode("",                  forKey: .payload)
    }
    try container.encodeIfPresent(self.silent,  forKey: .silent)
  }
}
