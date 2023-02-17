//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/6/23.
//

import Foundation
import CryptoSwift

extension Data {
  func encrypt(key: Data) throws -> WCSocketMessage.EncrypedPayload {
    let ivBytes = [UInt8].randomBytes(16)
    let keyBytes = key.bytes
    let aesCipher = try AES(key: keyBytes, blockMode: CBC(iv: ivBytes))
    let cipherInput = self.bytes
    let encryptedBytes = try aesCipher.encrypt(cipherInput)

    let data = encryptedBytes.toHexString()
    let iv = ivBytes.toHexString()
    let hmac = try (encryptedBytes + ivBytes).hmac(key: key)

    return WCSocketMessage.EncrypedPayload(data: data, hmac: hmac, iv: iv)
  }
}

extension WCSocketMessage.EncrypedPayload {
  func decrypt(_ key: Data) throws -> Data {
    let keyBytes = key.bytes
    let dataBytes = Data(hex: data).bytes
    let ivBytes = Data(hex: iv).bytes
    
    let computedHmac = try (dataBytes + ivBytes).hmac(key: key)
    
    guard computedHmac == hmac else {
      throw WalletConnectProvider.Error.badServerResponse
    }
    
    let aesCipher = try AES(key: keyBytes, blockMode: CBC(iv: ivBytes))
    let decryptedBytes = try aesCipher.decrypt(dataBytes)
    
    return Data(decryptedBytes)
  }
}
