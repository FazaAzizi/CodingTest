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
    private let networkManager = NetworkManager.shared
    
    func getClaims() -> AnyPublisher<[Claim], Error> {
        let url = "\(Constants.baseURL)/posts"
        return networkManager.request(url)
    }
}
