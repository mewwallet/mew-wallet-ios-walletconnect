//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/6/23.
//

import Foundation

extension Array where Element == UInt8 {
  static func randomBytes(_ n: Int) -> [UInt8] {
    var bytes = [UInt8].init(repeating: 0, count: n)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    if status != errSecSuccess {
      for i in 1...bytes.count {
        bytes[i] = UInt8(arc4random_uniform(256))
      }
    }
    return bytes
  }
}
