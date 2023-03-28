# mew-wallet-ios-walletconnect

Package that allows to support WalletConnect v1 and v2.

1. WC1 only: There's no built-in session storage for sessions. App must implement that. **For example only**:

```
final class Storage: WC1.SessionStorage {
  var sessions: [WC1.Session] = []
  
  init() {
    do {
      guard let data = UserDefaults.standard.object(forKey: "sessions") as? Data else { return }
      let decoder = JSONDecoder()
      self.sessions = try decoder.decode([WC1.Session].self, from: data)
    } catch {
      // Catch an error
    }
  }
  
  func add(_ session: WC1.Session) {
    sessions.append(session)
    _save()
  }
  
  func delete(_ session: WC1.Session, reason: WC1.Reason) {
    sessions.removeAll(where: { $0 == session })
    _save()
  }
  
  func save() {
    _save()
  }
  
  func clear() {
    sessions.removeAll()
    _save()
  }
  
  private func _save() {
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(self.sessions)
      UserDefaults.standard.set(data, forKey: "sessions")
    } catch {
      // Catch an error
    }
  }
}
```

2. Configuration:

```
let metadata = WC2.AppMetadata(name: "Wallet", description: "Description", url: "https://URL", icons: [])
WalletConnectProvider.instance.configure(projectId: "PROJECT_ID_FROM_WC_CLOUD", metadata: metadata, storage: storage)
```

3. Handling proposals:

```
WalletConnectProvider.instance.events.sessionProposal
  .sink {[weak self] proposal in
    switch proposal {
    case .v1:   self?._handleV1(proposal: proposal)
    case .v2:   self?._handleV2(proposal: proposal)
    }
  }
  .store(in: &cancellables)
        
...
          
private func _handleV1(proposal: SessionProposal) {
  guard case .v1(let request, _) = proposal else { return }
  guard case .wc_sessionRequest(let sessionRequest) = request.method else { return }
  Task {
    do {
      if !approved {
        try await WalletConnectProvider.instance.reject(proposal: proposal, reason: .userRejected)
      } else {
        try await WalletConnectProvider.instance.approve(proposal: proposal, accounts: address, chainId: 1)
      }
    } catch {
      // Handle error
    }
  }
}
```

4. Handling session requests:

```
WalletConnectProvider.instance.events.sessionRequest
  .sink(receiveValue: {[weak self] request in
    switch request {
    case .v1:   self?._handleV1(request: request)
    case .v2:   self?._handleV2(request: request)
    }
  })
  .store(in: &cancellables)
  
...

private func _handleV1(request: mew_wallet_ios_walletconnect.Request) {
  guard case .v1(let wc1request, _) = request else { return }
  switch wc1request.method {
  case .eth_personalSign(let address, _, let message):
    Task {
      do {
        if !approved {
          try await WalletConnectProvider.instance.reject(request: request)
        } else {
          try await WalletConnectProvider.instance.approve(request: request, result: "0xSIGNATURE_STRING_IN_HEX")
        }
      } catch {
        // Handle error
      }
    }
  default:
    break
  }
}
```
