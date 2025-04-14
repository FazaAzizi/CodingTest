//
//  ClaimDetailViewController.swift
//  CodingTest
//
//  Created by Faza Azizi on 14/04/25.
//

import UIKit

class ClaimDetailViewController: UIViewController {

    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    private var viewModel: ClaimDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func configure(with claim: Claim) {
        viewModel = ClaimDetailViewModel(claim: claim)
        title = "Claim Details"
        
        if isViewLoaded {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard viewModel != nil else { return }
        
        userIdLabel.text = "\(viewModel.claim.userId)"
        idLabel.text = "\(viewModel.claim.id)"
        titleLabel.text = viewModel.claim.title
        bodyLabel.text = viewModel.claim.body
    }

}
