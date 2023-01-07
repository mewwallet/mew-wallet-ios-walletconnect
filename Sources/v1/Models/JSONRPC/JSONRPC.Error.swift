//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import Foundation

extension JSONRPC {
  enum Error: LocalizedError, Codable {
    private enum CodingKeys: CodingKey {
      case code
      case message
    }
    
    case rejected
    case unknown
    
    var code: Int {
      switch self {
      case .rejected:     return -32000
      case .unknown:      return -1
      }
    }
    
    var localizedDescription: String {
      switch self {
      case .rejected:     return NSLocalizedString("Rejected", comment: "Request rejected")
      case .unknown:      return NSLocalizedString("Unknown error", comment: "Unknown error")
      }
    }
    
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: JSONRPC.Error.CodingKeys.self)
      
      let code = try container.decode(Int.self, forKey: .code)
      
      switch code {
      case -32000:      self = .rejected
      default:          self = .unknown
      }
    }
    
    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: JSONRPC.Error.CodingKeys.self)
      
      try container.encode(code,                  forKey: .code)
      try container.encode(localizedDescription,  forKey: .message)
    }
  }
}
