//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/14/23.
//

import Foundation
import WalletConnectPush

public final class PushOnSign: Sendable {
  private let uuid = UUID()
  
  init() {}
// FIXME: Re-do push notifications
  
//  public let payload: String
//  public let account: Account
//  var continuation: CheckedContinuation<SigningResult, Never>?
//  
//  init(payload: String, account: Account, continuation: CheckedContinuation<SigningResult, Never>) {
//    self.account = account
//    self.payload = payload
//    self.continuation = continuation
//  }
//  
//  deinit {
//    guard let continuation else { return }
//    continuation.resume(returning: .rejected)
//  }
//  
//  public func reject() {
//    guard let continuation else { return }
//    self.continuation = nil
//    continuation.resume(returning: .rejected)
//  }
//  
//  public func fulfill(_ signature: String) {
//    guard let continuation else { return }
//    self.continuation = nil
//    let signature = CacaoSignature(t: .eip191, s: signature)
//    continuation.resume(returning: .signed(signature))
//  }
}

extension PushOnSign: Equatable {
  public static func == (lhs: PushOnSign, rhs: PushOnSign) -> Bool {
    return lhs.uuid == rhs.uuid
  }
}
