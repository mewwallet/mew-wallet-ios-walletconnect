//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import Foundation
import mew_wallet_ios_walletconnect_v2

public enum Session {
  case v2(session: WC2.Session)
}

// MARK: - Session + Comparable

extension Session: Comparable {
  public static func < (lhs: Session, rhs: Session) -> Bool {
    switch (lhs, rhs) {
    case (.v2(let lhsSession), .v2(let rhsSession)):
      return lhsSession < rhsSession
    }
  }
}

// MARK: - Session + Sendable

extension Session: Sendable {}
