//
//  ClaimServiceProtocol.swift
//  CodingTest
//
//  Created by Faza Azizi on 14/04/25.
//

import Foundation
import Combine

protocol ClaimServiceProtocol {
    func getClaims() -> AnyPublisher<[Claim], Error>
}

class ClaimService: ClaimServiceProtocol {
    func getClaims() -> AnyPublisher<[Claim], Error> {
        return Fail(error: NSError(domain: "Not implemented", code: 0, userInfo: nil))
            .eraseToAnyPublisher()
    }
}
