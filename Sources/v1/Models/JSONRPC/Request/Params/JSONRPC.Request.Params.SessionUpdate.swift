//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/6/23.
//

import Foundation

extension JSONRPC.Request.Params {
  public struct SessionUpdate: Codable {
    public let approved: Bool
    public let chainId: UInt64?
    public let accounts: [String]?
  }
}

// MARK: - JSONRPC.Request.Params.SessionUpdate + Equatable

extension JSONRPC.Request.Params.SessionUpdate: Equatable {}
