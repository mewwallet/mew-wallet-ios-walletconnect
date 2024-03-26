import Foundation
import WalletConnectSign
import WalletConnectVerify
import WalletConnectUtils
import WalletConnectPush
import WalletConnectRelay
import Auth

public typealias SessionNamespace = WalletConnectSign.SessionNamespace
public typealias SignClient = WalletConnectSign.SignClient
public typealias Session = WalletConnectSign.Session
public typealias VerifyContext = WalletConnectVerify.VerifyContext
public typealias Request = WalletConnectSign.Request
public typealias WCAuthRequest = AuthRequest
public typealias WCCryptoProvider = CryptoProvider
public typealias WCBIP44Provider = BIP44Provider
public typealias Response = WalletConnectSign.Response
public typealias Account = WalletConnectSign.Account
public typealias AppMetadata = WalletConnectSign.AppMetadata
public typealias SocketConnectionStatus = WalletConnectRelay.SocketConnectionStatus
public typealias Reason = WalletConnectNetworking.Reason
public typealias Blockchain = WalletConnectUtils.Blockchain
public typealias RejectionReason = WalletConnectSign.RejectionReason
public typealias SIWECacaoFormatter = WalletConnectUtils.SIWECacaoFormatter
public typealias APNSEnvironment = WalletConnectPush.APNSEnvironment
public typealias WebSocketFactory = WalletConnectRelay.WebSocketFactory
public typealias WebSocketConnecting = WalletConnectRelay.WebSocketConnecting
