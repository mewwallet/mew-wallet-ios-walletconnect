//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import Foundation

extension WalletConnectProvider {
  public enum Error: LocalizedError {
    case badServerResponse
    case badResult
    case sessionExist
  }
}
