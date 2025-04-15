//
//  ClaimServiceTests.swift
//  CodingTestTests
//
//  Created by Faza Azizi on 15/04/25.
//

import XCTest
@testable import CodingTest

final class ClaimServiceTests: XCTestCase {

    var sut: ClaimService!
    
    override func setUp() {
        super.setUp()
        sut = ClaimService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testGetClaimsReturnsData() {
        let expectation = self.expectation(description: "Fetch claims")
        var receivedClaims: [Claim]?
        var receivedError: Error?
        
        let cancellable = sut.getClaims()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { claims in
                receivedClaims = claims
            })
        
        waitForExpectations(timeout: 5)
        XCTAssertNil(receivedError, "Should not receive an error")
        XCTAssertNotNil(receivedClaims, "Should receive claims")
        XCTAssertGreaterThan(receivedClaims?.count ?? 0, 0, "Should receive at least one claim")
        
        cancellable.cancel()
    }
}
