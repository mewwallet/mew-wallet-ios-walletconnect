//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import Foundation
@preconcurrency import WalletConnectSign

extension Request {
  public struct Params {
    // MARK: - Transaction
    
    public struct Transaction: Codable {
      public struct AccessListItem: Codable {
        public var address: String
        public var storageKeys: [String]
        
        public init(address: String, storageKeys: [String]) {
          self.address = address
          self.storageKeys = storageKeys
        }
      }
      
      public let type: String?
      public let chainId: String?
      public let from: String
      public let to: String?
      public let gasPrice: String?
      public let gas: String?
      public let maxFeePerGas: String?
      public let maxPriorityFeePerGas: String?
      public let value: String?
      public let nonce: String?
      public let data: String
      public let accessList: [AccessListItem]?
      
      private enum CodingKeys: CodingKey {
        case type
        case chainId
        case from
        case to
        case gasPrice
        case gas
        case gasLimit
        case maxFeePerGas
        case maxPriorityFeePerGas
        case value
        case nonce
        case data
        case accessList
      }
      
      public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        self.type                   = try container.decodeIfPresent(String.self,            forKey: .type)
        self.chainId                = try container.decodeIfPresent(String.self,            forKey: .chainId)
        self.from                   = try container.decode(String.self,                     forKey: .from)
        self.to                     = try container.decodeIfPresent(String.self,            forKey: .to)
        self.gasPrice               = try container.decodeIfPresent(String.self,            forKey: .gasPrice)
        if let gas                  = try container.decodeIfPresent(String.self,            forKey: .gas) {
          self.gas = gas
        } else if let gasLimit      = try container.decodeIfPresent(String.self,            forKey: .gasLimit) {
          self.gas = gasLimit
        } else {
          self.gas = nil
        }
        self.maxFeePerGas           = try container.decodeIfPresent(String.self,            forKey: .maxFeePerGas)
        self.maxPriorityFeePerGas   = try container.decodeIfPresent(String.self,            forKey: .maxPriorityFeePerGas)
        self.value                  = try container.decodeIfPresent(String.self,            forKey: .value)
        self.nonce                  = try container.decodeIfPresent(String.self,            forKey: .nonce)
        self.data                   = try container.decode(String.self,                     forKey: .data)
        self.accessList             = try container.decodeIfPresent([AccessListItem].self,  forKey: .accessList)
      }
      
      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.type,                  forKey: .type)
        try container.encodeIfPresent(self.chainId,               forKey: .chainId)
        try container.encode(self.from,                           forKey: .from)
        try container.encodeIfPresent(self.to,                    forKey: .to)
        try container.encodeIfPresent(self.gasPrice,              forKey: .gasPrice)
        try container.encodeIfPresent(self.gas,                   forKey: .gas)
        try container.encodeIfPresent(self.maxFeePerGas,          forKey: .maxFeePerGas)
        try container.encodeIfPresent(self.maxPriorityFeePerGas,  forKey: .maxPriorityFeePerGas)
        try container.encodeIfPresent(self.value,                 forKey: .value)
        try container.encodeIfPresent(self.nonce,                 forKey: .nonce)
        try container.encode(self.data,                           forKey: .data)
        try container.encodeIfPresent(self.accessList,            forKey: .accessList)
      }
    }
    
    // MARK: - ChainID
    
    public struct ChainID: Codable {
      public let chainId: String
    }
  }
}
