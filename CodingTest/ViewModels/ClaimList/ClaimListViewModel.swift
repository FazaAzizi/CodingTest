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
        loadClaims()
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
        error = nil
        
        claimService.getClaims()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] claims in
                self?.allClaims = claims
            }
            .store(in: &cancellables)
    }
}
