import os
import WalletConnectSign
import WalletConnectUtils
import WalletConnectPairing
import WalletConnectEcho
import WalletConnectPush
import WalletConnectRouter
import Auth
import Combine
import Foundation
import mew_wallet_ios_logger

public enum WalletConnectServiceError: Error {
  case invalidPairingURL
  case badParameters
}

public final class WalletConnectProvider {
  public static let instance = WalletConnectProvider()
  
  public let events = WalletConnectSessionPublisher()
  
  /// Query sessions
  /// - Returns: All sessions
  public var sessions: [Session] {
    Sign.instance.getSessions()
  }
  
  private var publishers = [AnyCancellable]()
  
  /// Query pending requests
  /// - Returns: Pending requests received from peer with `wc_sessionRequest` protocol method
  /// - Parameter topic: topic representing session for which you want to get pending requests. If nil, you will receive pending requests for all active sessions.
  public func getPendingRequests(topic: String? = nil) -> [Request] {
    return Sign.instance.getPendingRequests(topic: topic)
  }

  public func configure(projectId: String, metadata: AppMetadata, cryptoProvider: CryptoProvider) {
    Networking.configure(projectId: projectId, socketFactory: SocketFactory())
    Pair.configure(metadata: metadata)
    Auth.configure(crypto: cryptoProvider)
    
    // FIXME: For now we're not supporting WC2 push notifications
    Push.configure(echoHost: "staging.mewwallet.dev/v2/wallet-connect", environment: .sandbox)
    
    Push.wallet.requestPublisher.sink { (id: RPCID, account: Account, metadata: AppMetadata) in
      Logger.critical(.provider, "okok \(account)")
    }.store(in: &publishers)
    
    Push.wallet.pushMessagePublisher.sink { pm in
      Logger.critical(.provider, "okok 22 \(pm)")
    }.store(in: &publishers)
  }
  
  /// For wallet to establish a pairing
  /// Wallet should call this function in order to accept peer's pairing proposal and be able to subscribe for future requests.
  /// - Parameter uri: Pairing URI that is commonly presented as a QR code by a dapp or delivered with universal linking.
  ///
  /// Throws Error:
  /// - When URI is invalid format or missing params
  /// - When topic is already in use
  public func pair(url: String) async throws {
    guard let wcURL = WalletConnectURI(string: url) else { throw WalletConnectServiceError.invalidPairingURL }
    try await Pair.instance.pair(uri: wcURL)
  }
  
  public func approve(request: Request, result: any Codable) async throws {
    try await respond(
      topic: request.topic,
      requestId: request.id,
      response: .response(AnyCodable(result))
    )
  }
  
  public func reject(request: Request) async throws {
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
  
  public func approve(proposal: Session.Proposal, chains: [UInt64], accounts: [String]) async throws {
    let chains = chains.compactMap({ Blockchain(namespace: "eip155", reference: String($0)) })
    
    let accounts = chains.flatMap({ chain in
      accounts.compactMap({ Account(blockchain: chain, address: $0) })
    })
    
    let methods = proposal.requiredNamespaces.values.flatMap({ $0.methods })
    
    let events = proposal.requiredNamespaces.values.flatMap({ $0.events })
    let namespaces = try AutoNamespaces.build(sessionProposal: proposal,
                                              chains: chains,
                                              methods: methods,
                                              events: events,
                                              accounts: accounts)
    try await approve(proposalId: proposal.id, namespaces: namespaces)
  }
  
  /// For a wallet to approve a session proposal.
  /// - Parameters:
  ///   - proposalId: Session Proposal id
  ///   - namespaces: namespaces for given session, needs to contain at least required namespaces proposed by dApp.
  public func approve(proposalId: String, namespaces: [String: SessionNamespace]) async throws {
    try await Sign.instance.approve(proposalId: proposalId, namespaces: namespaces)
  }
  
  public func approve(authRequest: WCAuthRequest, signature: String, chainId: UInt64, address: String) async throws {
    guard let blockchain = Blockchain(namespace: "eip155", reference: String(chainId)) else { return }
    guard let account = Account(blockchain: blockchain, address: address) else { return }
    let signature = CacaoSignature(t: .eip191, s: signature)
    try await Auth.instance.respond(requestId: authRequest.id, signature: signature, from: account)
  }
  
  public func reject(authRequest: AuthRequest) async throws {
    try await Auth.instance.reject(requestId: authRequest.id)
  }
  
  /// For the wallet to update session namespaces
  /// - Parameters:
  ///   - topic: Topic of the session that is intended to be updated.
  ///   - namespaces: Dictionary of namespaces that will replace existing ones.
  public func update(topic: String, namespaces: [String: SessionNamespace]) async throws {
    try await Sign.instance.update(topic: topic, namespaces: namespaces)
  }
  
  public func update(session: Session, chainId: UInt64?, accounts: [String]) async throws {
    var sessionNamespaces = [String: SessionNamespace]()
    session.namespaces.forEach {
      let caip2Namespace = $0.key
      let proposalNamespace = $0.value
      let accounts = Set(
        proposalNamespace.accounts.flatMap({ namespace in
          accounts.compactMap { address in
            var blockchain = namespace.blockchain
            if let chainId {
              blockchain = Blockchain(namespace: blockchain.namespace, reference: "\(chainId)") ?? blockchain
            }
            return Account(chainIdentifier: blockchain.absoluteString, address: address)
          }
        })
      )
      
      let sessionNamespace = SessionNamespace(accounts: accounts, methods: proposalNamespace.methods, events: proposalNamespace.events)
      sessionNamespaces[caip2Namespace] = sessionNamespace
      
      sessionNamespaces[caip2Namespace] = sessionNamespace
    }
    try await Sign.instance.update(topic: session.topic, namespaces: sessionNamespaces)
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
  ///   - session: Session that you want to delete
  public func disconnect(session: Session) async throws {
    try await Sign.instance.disconnect(topic: session.topic)
  }
  
  public func register(pushToken token: Data) {
    Task(priority: .userInitiated) {
      do {
        try await Push.wallet.register(deviceToken: token)
        Logger.error(.provider, "Registered")
      } catch {
        Logger.error(.provider, "Error: \(error)")
      }
    }
  }
  
  public func goBack() {
    WalletConnectRouter.Router.goBack()
  }
}
