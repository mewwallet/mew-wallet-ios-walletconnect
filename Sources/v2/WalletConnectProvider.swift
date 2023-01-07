import WalletConnectSign
import WalletConnectUtils
import WalletConnectPairing
import Combine
import Foundation

public enum WalletConnectServiceError: Error {
  case invalidPairingURL
}

public final class WalletConnectProvider {
  public static let instance = WalletConnectProvider()
  
  public let events = WalletConnectSessionPublisher()
  
  /// Query sessions
  /// - Returns: All sessions
  public var sessions: [Session] {
    Sign.instance.getSessions()
  }
  
  /// Query pending requests
  /// - Returns: Pending requests received from peer with `wc_sessionRequest` protocol method
  /// - Parameter topic: topic representing session for which you want to get pending requests. If nil, you will receive pending requests for all active sessions.
  public func getPendingRequests(topic: String? = nil) -> [Request] {
    return Sign.instance.getPendingRequests(topic: topic)
  }

  public func configure(projectId: String, metadata: AppMetadata) {
    Networking.configure(projectId: projectId, socketFactory: SocketFactory())
    Pair.configure(metadata: metadata)
  }
  
  /// For wallet to establish a pairing
  /// Wallet should call this function in order to accept peer's pairing proposal and be able to subscribe for future requests.
  /// - Parameter uri: Pairing URI that is commonly presented as a QR code by a dapp or delivered with universal linking.
  ///
  /// Throws Error:
  /// - When URI is invalid format or missing params
  /// - When topic is already in use
  public func pair(url: String?) async throws {
    guard let url = url, let wcURL = WalletConnectURI(string: url) else {
      throw WalletConnectServiceError.invalidPairingURL
    }
    try await Pair.instance.pair(uri: wcURL)
  }
  
  public func respondOnSign(request: Request, result: AnyCodable) async throws {
    try await respond(
      topic: request.topic,
      requestId: request.id,
      response: .response(result)
    )
  }
  
  public func respondOnReject(request: Request) async throws {
    try await WalletConnectProvider.instance.respond(
      topic: request.topic,
      requestId: request.id,
      response: .error(.init(code: 0, message: ""))
    )
  }
  
  /// For the wallet to respond on pending dApp's JSON-RPC request
  /// - Parameters:
  ///   - topic: Topic of the session for which the request was received.
  ///   - requestId: RPC request ID
  ///   - response: Your JSON RPC response or an error.
  public func respond(topic: String, requestId: RPCID, response: RPCResult) async throws {
    try await Sign.instance.respond(topic: topic, requestId: requestId, response: response)
  }
  
  public func approve(proposal: SessionProposal, account: String) async throws {
    var sessionNamespaces = [String: SessionNamespace]()
    proposal.requiredNamespaces.forEach {
      let caip2Namespace = $0.key
      let proposalNamespace = $0.value
      let accounts = Set(proposalNamespace.chains.compactMap { Account($0.absoluteString + ":\(account)") })
      
      let extensions: [SessionNamespace.Extension]? = proposalNamespace.extensions?.map { element in
        let accounts = Set(element.chains.compactMap { Account($0.absoluteString + ":\(account)") })
        return SessionNamespace.Extension(accounts: accounts, methods: element.methods, events: element.events)
      }
      let sessionNamespace = SessionNamespace(
        accounts: accounts,
        methods: proposalNamespace.methods,
        events: proposalNamespace.events,
        extensions: extensions
      )
      sessionNamespaces[caip2Namespace] = sessionNamespace
    }
    try await approve(proposalId: proposal.id, namespaces: sessionNamespaces)
  }
  
  /// For a wallet to approve a session proposal.
  /// - Parameters:
  ///   - proposalId: Session Proposal id
  ///   - namespaces: namespaces for given session, needs to contain at least required namespaces proposed by dApp.
  public func approve(proposalId: String, namespaces: [String: SessionNamespace]) async throws {
    try await Sign.instance.approve(proposalId: proposalId, namespaces: namespaces)
  }
  
  /// For the wallet to update session namespaces
  /// - Parameters:
  ///   - topic: Topic of the session that is intended to be updated.
  ///   - namespaces: Dictionary of namespaces that will replace existing ones.
  public func update(topic: String, namespaces: [String: SessionNamespace]) async throws {
    try await Sign.instance.update(topic: topic, namespaces: namespaces)
  }
  
  /// For the wallet to reject a session proposal.
  /// - Parameters:
  ///   - proposalId: Session Proposal id
  ///   - reason: Reason why the session proposal has been rejected. Conforms to CAIP25.
  public func reject(proposalId: String, reason: RejectionReason) async throws {
    try await Sign.instance.reject(proposalId: proposalId, reason: reason)
  }
  
  /// Ping method allows to check if peer client is online and is subscribing for given topic
  ///
  ///  Should Error:
  ///  - When the session topic is not found
  ///
  /// - Parameters:
  ///   - topic: Topic of a session
  public func ping(topic: String) async throws {
    try await Sign.instance.ping(topic: topic)
  }
  
  /// For a wallet and a dApp to terminate a session
  ///
  /// Should Error:
  /// - When the session topic is not found
  /// - Parameters:
  ///   - topic: Session topic that you want to delete
  public func disconnect(topic: String) async throws {
    try await Sign.instance.disconnect(topic: topic)
  }
}
