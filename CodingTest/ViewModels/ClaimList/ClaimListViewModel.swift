//
//  ClaimListViewModel.swift
//  CodingTest
//
//  Created by Faza Azizi on 14/04/25.
//

import Foundation
import Combine

class ClaimListViewModel {
    private let claimService: ClaimServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var allClaims: [Claim] = []
    @Published var filteredClaims: [Claim] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var error: Error?
    
    init(claimService: ClaimServiceProtocol = ClaimService()) {
        self.claimService = claimService
        setupBindings()
        loadDummyClaims()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest($searchText, $allClaims)
            .map { query, claims in
                if query.isEmpty {
                    return claims
                } else {
                    return claims.filter { claim in
                        claim.title.lowercased().contains(query.lowercased()) ||
                        claim.body.lowercased().contains(query.lowercased())
                    }
                }
            }
            .assign(to: &$filteredClaims)
    }
    
    func loadClaims() {
        if isLoading { return }
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.allClaims = self.createDummyClaims(count: 20)
            self.isLoading = false
        }
    }
    
    private func loadDummyClaims() {
        allClaims = createDummyClaims(count: 20)
    }
    
    private func createDummyClaims(count: Int) -> [Claim] {
        var claims: [Claim] = []
        
        for i in 1...count {
            let claim = Claim(
                userId: 100 + (i % 10),
                id: i,
                title: "Insurance Claim \(i)",
                body: "This is a detailed description for insurance claim \(i). It contains information about the incident, damages, and other relevant details for processing the claim."
            )
            claims.append(claim)
        }
        
        return claims
    }
}

