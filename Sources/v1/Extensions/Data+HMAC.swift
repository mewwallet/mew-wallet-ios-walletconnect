//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/6/23.
//

import Foundation
import CryptoSwift

extension Data {
  func hmac(key: Data) throws -> String {
    try self.bytes.hmac(key: key)
  }
}
