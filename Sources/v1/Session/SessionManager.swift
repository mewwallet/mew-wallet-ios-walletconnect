//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import os
import Foundation
import Combine
import mew_wallet_ios_logger

final class SessionManager {
  private var _cancellables = Set<AnyCancellable>()
  
  private let sessionProposalSubject = PassthroughSubject<(JSONRPC.Request, Session), Never>()
  private let requestSubject = PassthroughSubject<(JSONRPC.Request, Session), Never>()
  private let sessionDeleteSubject = PassthroughSubject<(String, Reason), Never>()
  
  var sessionProposalPublisher: AnyPublisher<(JSONRPC.Request, Session), Never> { sessionProposalSubject.eraseToAnyPublisher() }
  var requestPublisher: AnyPublisher<(JSONRPC.Request, Session), Never> { requestSubject.eraseToAnyPublisher() }
  var sessionDeletePublisher: AnyPublisher<(String, Reason), Never> { sessionDeleteSubject.eraseToAnyPublisher() }
  
  internal var storage: SessionStorage {
    guard let _storage else {
      fatalError("_storage must be set via `configure`")
    }
    return _storage
  }
  
  private var _storage: SessionStorage?
  private let _network = NetworkingInteractor()
  
  init() {
    _network.connectionStatusPublisher
      .sink {[weak self] status in
        switch status {
        case .connected(let session):
          self?._subscribe(session: session)
          
        case .disconnected:
          break
        }
      }
      .store(in: &_cancellables)
    
    _network.messagePublisher
      .compactMap {[weak self] message in
        debugPrint(">>>> \(message)")
        guard let session = self?.storage.session(with: message.topic) else { return nil }
        guard let payload = message.payload else { return nil }
        do {
          return (session, try session.decrypt(payload: payload))
        } catch {
          Logger.error(.sessionManager, "Decrypt message: \(error)")
          return nil
        }
      }
      .compactMap { (session: Session, data: Data) in
        debugPrint(String(data: data, encoding: .utf8))
        do {
          let decoder = JSONDecoder()
          return (session, try decoder.decode(JSONRPC.Request.self, from: data))
        } catch {
          Logger.error(.sessionManager, "Decode decrypted message: \(error)")
          return nil
        }
      }
      .sink {[weak self] (session: Session, request: JSONRPC.Request) in
        switch request.method {
        case .wc_sessionRequest(let proposal):
          session.update(with: proposal)
          self?.storage.save()
          self?.sessionProposalSubject.send((request, session))
        case .wc_sessionUpdate(let update):
          if !update.approved {
            let reason = JSONRPC.Error.disconnected
            self?.storage.delete(session, reason: reason)
            self?.sessionDeleteSubject.send((session.topic, reason))
            self?._network.disconnect(session: session)
          } else {
            session.update(with: update)
            self?.storage.save()
          }
          return
        default:
          self?.requestSubject.send((request, session))
        }
      }
      .store(in: &_cancellables)
  }
  
  func configure(storage: SessionStorage) {
    _storage = storage
    let sessions = storage.sessions
    Task(priority: .high) {[weak self] in
      sessions.forEach {
        self?._network.connect($0)
      }
    }
  }
  
  func add(_ uri: WalletConnectURI) throws {
    let session = Session(uri: uri)
    guard !self.storage.contains(session) else { throw WalletConnectProvider.Error.sessionExist }
    self.storage.add(session)
    Task(priority: .high) {[weak self] in
      self?._network.connect(session)
    }
  }
  
  func disconnect(session: Session) {
    let reason = JSONRPC.Error.disconnected
    self.storage.delete(session, reason: reason)
    self.sessionDeleteSubject.send((session.topic, reason))
  }
  
  func send<T: Codable>(message: T, for session: Session) throws {
    let encoder = JSONEncoder()
    let data = try encoder.encode(message)
    let encrypted = try session.encrypt(data: data)
    let message = WCSocketMessage(topic: session.peerId ?? session.topic, type: .pub, payload: encrypted)
    try _network.send(message: message, to: session)
  }
  
  // MARK: - Private
  
  private func _subscribe(session: Session) {
    do {
      // Subscribe on topic
      let topicMessage = WCSocketMessage(topic: session.topic, type: .sub)
      try _network.send(message: topicMessage, to: session)
      
      // Subscribe on UUID
      let uuidMessage = WCSocketMessage(topic: session.uuid, type: .sub)
      try _network.send(message: uuidMessage, to: session)
    } catch {
      Logger.error(.sessionManager, "Subscription error: \(error)")
    }
  }
}
