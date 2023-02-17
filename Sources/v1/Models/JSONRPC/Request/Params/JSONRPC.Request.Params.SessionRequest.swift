//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/6/23.
//

import Foundation

extension JSONRPC.Request.Params {
  public struct SessionRequest: Codable {
    public let peerId: String
    public let peerMeta: Session.AppMetadata
    public let chainId: UInt64?
  }
}

// MARK: - JSONRPC.Request.Params.SessionRequest + Equatable

extension JSONRPC.Request.Params.SessionRequest: Equatable {}
