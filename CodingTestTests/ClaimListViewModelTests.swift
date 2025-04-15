//
//  ClaimListViewModelTests.swift
//  CodingTestTests
//
//  Created by Faza Azizi on 15/04/25.
//

import XCTest
import Combine

@testable import CodingTest

class ClaimListViewModelTests: XCTestCase {
    
    var sut: ClaimListViewModel!
    var mockClaimService: MockClaimService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockClaimService = MockClaimService()
        sut = ClaimListViewModel(claimService: mockClaimService)
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        mockClaimService = nil
        super.tearDown()
    }
    
    func testLoadClaimsSuccess() {
        let expectedClaims = [
            Claim(userId: 1, id: 1, title: "Test Claim", body: "Test body")
        ]
        mockClaimService.mockClaims = expectedClaims
        
        let expectation = self.expectation(description: "Load claims")
        
        sut.$allClaims
            .dropFirst()
            .sink { claims in
                XCTAssertEqual(claims.count, expectedClaims.count)
                XCTAssertEqual(claims.first?.id, expectedClaims.first?.id)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.loadClaims()
        
        waitForExpectations(timeout: 1)
    }
    
    func testSearchFiltering() {
        let claims = [
            Claim(userId: 1, id: 1, title: "Insurance Claim", body: "Test body"),
            Claim(userId: 2, id: 2, title: "Another Claim", body: "Different content")
        ]
        sut.allClaims = claims
        
        let expectation = self.expectation(description: "Filter claims")
        
        sut.$filteredClaims
            .dropFirst()
            .sink { filteredClaims in
                XCTAssertEqual(filteredClaims.count, 1)
                XCTAssertEqual(filteredClaims.first?.id, 1)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchText = "Insurance"
        
        waitForExpectations(timeout: 1)
    }
}

class MockClaimService: ClaimServiceProtocol {
    var mockClaims: [Claim] = []
    var mockError: Error?
    
    func getClaims() -> AnyPublisher<[Claim], Error> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(mockClaims)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
