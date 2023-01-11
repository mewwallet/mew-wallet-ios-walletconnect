//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import Foundation

extension Request {
  public enum Method {
    case eth_sign(address: String, data: Data, message: String?)
    case eth_personalSign(address: String, data: Data, message: String?)
    case eth_signTypedData(address: String, message: Any)
    case eth_signTransaction(transaction: Request.Params.Transaction)
    case eth_sendTransaction(transaction: Request.Params.Transaction)
    case raw(method: String, params: String)
  }
}
