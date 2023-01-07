//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/6/23.
//

import Foundation
import CryptoSwift

extension Array where Element == UInt8 {
  func hmac(key: Data) throws -> String {
    return try HMAC(key: key.bytes, variant: .sha2(.sha256)).authenticate(self).toHexString()
  }
}
