//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import Foundation
import mew_wallet_ios_walletconnect_v1
import mew_wallet_ios_walletconnect_v2

public enum Session {
  case v1(session: WC1.Session)
  case v2(session: WC2.Session)
}

extension Session: Comparable {
  public static func < (lhs: Session, rhs: Session) -> Bool {
    switch (lhs, rhs) {
    case (.v1(let lhsSession), .v1(let rhsSession)):
      return lhsSession < rhsSession
    case (.v2(let lhsSession), .v2(let rhsSession)):
      return lhsSession < rhsSession
    case (.v1(let lhsSession), .v2(let rhsSession)):
      return lhsSession.created < rhsSession.created
    case (.v2(let lhsSession), .v1(let rhsSession)):
      return lhsSession.created < rhsSession.created
    }
  }
}
