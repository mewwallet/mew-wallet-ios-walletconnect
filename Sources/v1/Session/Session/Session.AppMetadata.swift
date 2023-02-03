//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 1/5/23.
//

import Foundation

// TODO: Refactor
extension Session {
  public struct AppMetadata: Codable {
    /// The name of the app.
    public let name: String
    /// The URL string that identifies the official domain of the app.
    public let url: String
    /// A brief textual description of the app that can be displayed to peers.
    public let description: String
    /// An array of URL strings pointing to the icon assets on the web.
    public let icons: [String]
    
    public init(name: String, url: String, description: String = "", icons: [String] = []) {
      self.name = name
      self.url = url
      self.description = description
      self.icons = icons
    }
  }
}

// MARK: - Session.AppMetadata + Equatable

extension Session.AppMetadata: Equatable {}
