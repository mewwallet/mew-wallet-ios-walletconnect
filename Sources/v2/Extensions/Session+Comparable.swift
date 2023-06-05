//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/30/23.
//

import Foundation

extension Session: Comparable {
  public static func < (lhs: Session, rhs: Session) -> Bool {
    lhs.expiryDate < rhs.expiryDate
  }
}
