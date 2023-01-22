//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/9/23.
//

import Foundation

public protocol Reason {
  var code: Int { get }
  var message: String { get }
}
