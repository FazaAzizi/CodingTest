//
//  ClaimListViewController.swift
//  CodingTest
//
//  Created by Faza Azizi on 14/04/25.
//

import UIKit
import Combine

class ClaimListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    private let viewModel = ClaimListViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
        viewModel.loadClaims()
    }
    
    private func setupUI() {
        title = "Claim List"
        
        searchBar.delegate = self
        searchBar.placeholder = "Search claims"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ClaimListTableViewCell.nib, forCellReuseIdentifier: ClaimListTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        emptyLabel.text = "No claims found"
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$filteredClaims
            .receive(on: RunLoop.main)
            .sink { [weak self] claims in
                self?.tableView.reloadData()
                self?.updateEmptyLabelVisibility(claims: claims)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.emptyLabel.isHidden = true
                } else {
                    self?.activityIndicator.stopAnimating()
                    if let claims = self?.viewModel.filteredClaims {
                         self?.updateEmptyLabelVisibility(claims: claims)
                     }
                }
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            }
            .store(in: &cancellables)
        
        viewModel.$searchText
            .receive(on: RunLoop.main)
            .sink { [weak self] searchText in
                if !searchText.isEmpty {
                    self?.emptyLabel.text = "No results found for '\(searchText)'"
                } else {
                    self?.emptyLabel.text = "No claims found"
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateEmptyLabelVisibility(claims: [Claim]) {
        if claims.isEmpty {
            emptyLabel.isHidden = false
            tableView.isHidden = true
        } else {
            emptyLabel.isHidden = true
            tableView.isHidden = false
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateToClaimDetail(claim: Claim) {
        let detailVC = ClaimDetailViewController()
        detailVC.configure(with: claim)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension ClaimListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredClaims.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ClaimListTableViewCell.identifier, for: indexPath) as? ClaimListTableViewCell else {
            return UITableViewCell()
        }
        
        let claim = viewModel.filteredClaims[indexPath.row]
        cell.configure(data: claim)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let claim = viewModel.filteredClaims[indexPath.row]
        navigateToClaimDetail(claim: claim)
    }
}

// MARK: - UISearchBarDelegate
extension ClaimListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
