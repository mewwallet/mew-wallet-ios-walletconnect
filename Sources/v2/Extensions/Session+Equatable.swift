//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/30/23.
//

import Foundation

extension Session: Equatable {
  public static func == (lhs: Session, rhs: Session) -> Bool {
    return lhs.topic == rhs.topic
  }
}
