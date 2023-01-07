//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/6/23.
//

import Foundation

extension JSONRPC {
  struct ApproveSession: Codable {
    public let approved: Bool
    public let chainId: Int
    public let accounts: [String]
    
    public let peerId: String?
    public let peerMeta: Session.AppMetadata?
  }
}
