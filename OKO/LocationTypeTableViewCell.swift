//
//  LocationTypeTableViewCell.swift
//  OKO
//
//  Created by ValKim on 3/21/16.
//  Copyright © 2016 oko. All rights reserved.
//

import UIKit

class LocationTypeTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var checkedImageView: UIImageView!
    @IBOutlet weak var typeImageView: UIImageView!
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
