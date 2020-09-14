import PocketNotifications
import XCTest

class NotificationsClientTests: XCTestCase {
    func testLiveClient() {
        _ = NotificationsClient.live
    }
    
    func testAuthorizedMock() {
        let client = NotificationsClient.authorized
        
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        
        client.authorize(options: []) { status in
            expectation.fulfill()
            XCTAssertTrue(status)
        }
        
        client.getAuthorizationStatus { status in
            expectation.fulfill()
            XCTAssertEqual(status, .authorized)
        }
        
        waitForExpectations(timeout: 0.0)
    }
    
    func testDeniedMock() {
        let client = NotificationsClient.denied
        
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        
        client.authorize(options: []) { status in
            expectation.fulfill()
            XCTAssertFalse(status)
        }
        
        client.getAuthorizationStatus { status in
            expectation.fulfill()
            XCTAssertEqual(status, .denied)
        }
        
        waitForExpectations(timeout: 0.0)
    }
}
