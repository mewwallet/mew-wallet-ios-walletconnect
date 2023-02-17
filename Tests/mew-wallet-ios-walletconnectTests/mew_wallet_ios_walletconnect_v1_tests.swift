import XCTest
@testable import mew_wallet_ios_walletconnect_v1

final class mew_wallet_ios_walletconnect_v1_tests: XCTestCase {
  func testWCURI_v1() throws {
    let testURI = "wc:5bd9a766-6890-43b2-9894-c318113f39c8@1?bridge=https%3A%2F%2F2.bridge.walletconnect.org&key=8cfff4e59585546e29bb000ad136899ef4c3a1c0c1c4fbd48d76c1c4f6397557"
    
    let uri = try WalletConnectURI(string: testURI)
    
    XCTAssertEqual(uri.topic, "5bd9a766-6890-43b2-9894-c318113f39c8")
    XCTAssertEqual(uri.version, "1")
    XCTAssertEqual(uri.bridge, URL(string: "https://2.bridge.walletconnect.org")!)
    XCTAssertEqual(uri.key, Data(hex: "8cfff4e59585546e29bb000ad136899ef4c3a1c0c1c4fbd48d76c1c4f6397557"))
    XCTAssertEqual(uri.absoluteString, testURI)
  }
}
