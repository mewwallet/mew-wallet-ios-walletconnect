//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import Foundation

extension WalletConnectURI {
  public enum Error: LocalizedError {
    case invalidVersion
    case invalidPairingURL
    case invalidPairingParameters
  }
}
