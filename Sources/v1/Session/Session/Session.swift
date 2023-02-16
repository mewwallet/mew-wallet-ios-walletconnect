//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import Foundation

public final class Session {
  private let _uri: WalletConnectURI
  private var _peerId: String?
  
  public let created: Date
  public let uuid: String
  var topic: String { _uri.topic }
  var peerId: String? { _peerId }
  public var bridge: URL { _uri.bridge }
  public var metadata: AppMetadata?
  public var chainId: UInt64 = 1
  public var accounts: [String] = []
  
  public init(uri: WalletConnectURI, uuid: String = UUID().uuidString, created: Date = Date()) {
    _uri = uri
    self.uuid = uuid
    self.created = created
  }
  
  func update(with sessionRequest: JSONRPC.Request.Params.SessionRequest) {
    _peerId = sessionRequest.peerId
    metadata = sessionRequest.peerMeta
    chainId = sessionRequest.chainId ?? chainId
  }
  
  func update(with sessionUpdate: JSONRPC.Request.Params.SessionUpdate) {
    chainId = sessionUpdate.chainId ?? chainId
    if let accounts = sessionUpdate.accounts, !accounts.isEmpty {
      self.accounts = accounts
    }
  }
  
  func update(with approve: JSONRPC.ApproveSession) {
    guard approve.approved else { return }
    chainId = approve.chainId
    accounts = approve.accounts
  }
  
  func decrypt(payload: WCSocketMessage.EncrypedPayload) throws -> Data {
    return try payload.decrypt(_uri.key)
  }
  
  func encrypt(data: Data) throws -> WCSocketMessage.EncrypedPayload {
    return try data.encrypt(key: _uri.key)
  }
}

extension Session: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(_uri)
  }
}

extension Session: Equatable {
  public static func == (lhs: Session, rhs: Session) -> Bool {
    return lhs._uri == rhs._uri
  }
}

extension Session: Codable {
  private enum CodingKeys: CodingKey {
    case uri
    case peerId
    case uuid
    case metadata
    case created
    case chainId
    case accounts
  }
  
  public convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let uriString   = try container.decode(String.self,                 forKey: .uri)
    let uri = try WalletConnectURI(string: uriString)
    let uuid        = try container.decode(String.self,                 forKey: .uuid)
    let created     = try? container.decodeIfPresent(Date.self,         forKey: .created)
    self.init(uri: uri, uuid: uuid, created: created ?? Date())
    _peerId         = try container.decodeIfPresent(String.self,        forKey: .peerId)
    metadata        = try container.decodeIfPresent(AppMetadata.self,   forKey: .metadata)
    chainId         = try container.decodeIfPresent(UInt64.self,        forKey: .chainId) ?? 1
    accounts        = try container.decodeIfPresent([String].self,      forKey: .accounts) ?? []
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_uri.absoluteString, forKey: .uri)
    try container.encode(uuid,                forKey: .uuid)
    try container.encodeIfPresent(_peerId,    forKey: .peerId)
    try container.encodeIfPresent(metadata,   forKey: .metadata)
    try container.encode(created,             forKey: .created)
    try container.encode(chainId,             forKey: .chainId)
    try container.encode(accounts,            forKey: .accounts)
  }
  
}

extension Session: Comparable {
  public static func < (lhs: Session, rhs: Session) -> Bool {
    lhs.created < rhs.created
  }
}
