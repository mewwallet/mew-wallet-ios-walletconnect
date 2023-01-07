//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import Foundation

extension JSONRPC {
  public enum ID: Codable {
    case int(Int64)
    case string(String)
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if let int = try? container.decode(Int64.self) {
        self = .int(int)
        return
      }
      let string = try container.decode(String.self)
      self = .string(string)
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case .int(let int):
        try container.encode(int)
      case .string(let string):
        try container.encode(string)
      }
    }
  }
}
