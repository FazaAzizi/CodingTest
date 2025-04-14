//
//  ClaimListTableViewCell.swift
//  CodingTest
//
//  Created by Faza Azizi on 14/04/25.
//

import UIKit

class ClaimListTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    static let identifier = String(describing: ClaimListTableViewCell.self)
    
    static let nib = {
       UINib(nibName: identifier, bundle: nil)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(data: Claim) {
        titleLabel.text = data.title 
        bodyLabel.text = data.body
    }
    
}
