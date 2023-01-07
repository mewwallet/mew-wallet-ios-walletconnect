import Foundation

public struct ActiveSessionItem {
  public let dappName: String
  public let dappURL: String
  public let iconURL: String
  public let topic: String
  
  public init(dappName: String, dappURL: String, iconURL: String, topic: String) {
    self.dappName = dappName
    self.dappURL = dappURL
    self.iconURL = iconURL
    self.topic = topic
  }
}
