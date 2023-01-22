//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import Foundation

public protocol SessionStorage {
  var sessions: [Session] { get }
  
  func add(_ session: Session)
  func delete(_ session: Session, reason: Reason)
  func save()
}

extension SessionStorage {
  func contains(_ session: Session) -> Bool {
    return self.sessions.firstIndex(of: session) != nil
  }
  
  func session(with topic: String) -> Session? {
    return sessions.first(where: { $0.uuid == topic || $0.topic == topic })
  }
}
