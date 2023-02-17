import WalletConnectSign

public struct Proposal {
  public let proposerName: String
  public let proposerDescription: String
  public let proposerURL: String
  public let iconURL: String
  public let permissions: [Namespace]
  
  public struct Namespace: Hashable {
    public let chains: [String]
    public let methods: [String]
    public let events: [String]
  }
  
  public init(proposal: Session.Proposal) {
    self.proposerName = proposal.proposer.name
    self.proposerDescription = proposal.proposer.description
    self.proposerURL = proposal.proposer.url
    self.iconURL = proposal.proposer.icons.first ?? "https://avatars.githubusercontent.com/u/37784886"
    self.permissions = [
      Namespace(
        chains: ["eip155:1"],
        methods: ["eth_sendTransaction", "personal_sign", "eth_signTypedData"],
        events: ["accountsChanged", "chainChanged"])]
  }
  
  public init(
    proposerName: String,
    proposerDescription: String,
    proposerURL: String,
    iconURL: String,
    permissions: [Proposal.Namespace]
  ) {
    self.proposerName = proposerName
    self.proposerDescription = proposerDescription
    self.proposerURL = proposerURL
    self.iconURL = iconURL
    self.permissions = permissions
  }
  
  public static func mock() -> Proposal {
    Proposal(
      proposerName: "Example name",
      proposerDescription: "loremIpsum",
      proposerURL: "example.url",
      iconURL: "https://avatars.githubusercontent.com/u/37784886",
      permissions: [
        Namespace(
          chains: ["eip155:1"],
          methods: ["eth_sendTransaction", "personal_sign", "eth_signTypedData"],
          events: ["accountsChanged", "chainChanged"]),
        Namespace(
          chains: ["cosmos:cosmoshub-2"],
          methods: ["cosmos_signDirect", "cosmos_signAmino"],
          events: [])
      ]
    )
  }
}
