import PocketNotifications
import XCTest

class NotificationsClientTests: XCTestCase {
    func testLiveClient() {
        _ = NotificationsClient.live
    }
    
    func testAuthorizedMock() {
        let client = NotificationsClient.authorized
        
        let expectation = self.expectation(description: #function)
        client.authorize(options: []) { granted in
            expectation.fulfill()
            XCTAssertTrue(granted)
        }
        
        
        waitForExpectations(timeout: 0.0)
    }
    
    func testAsyncAuthorizedMock() async throws {
        let client = NotificationsClient.authorized
        let granted = try await client.authorize(options: [])
        XCTAssertTrue(granted)
    }
    
    func testDeniedMock() {
        let client = NotificationsClient.denied
        
        let expectation = self.expectation(description: #function)
        client.authorize(options: []) { granted in
            expectation.fulfill()
            XCTAssertFalse(granted)
        }
        
        XCTAssertEqual(client.authorizationStatus(), .denied)
        
        waitForExpectations(timeout: 0.0)
    }
    
    func testAsyncDeniedMock() async throws {
        let client = NotificationsClient.denied
        let granted = try await client.authorize(options: [])
        XCTAssertFalse(granted)
    }
}
