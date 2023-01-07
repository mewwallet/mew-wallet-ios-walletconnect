//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import Foundation

extension JSONRPC {
  struct Response<T: Codable>: Codable {
    var jsonrpc = "2.0"
    let id: JSONRPC.ID
    let result: T?
    let error: Error?
    
    init(id: JSONRPC.ID, result: T?) {
      self.id = id
      self.result = result
      self.error = nil
    }
    
    init(id: JSONRPC.ID, error: Error) {
      self.id = id
      self.result = nil
      self.error = error
    }
  }
}
