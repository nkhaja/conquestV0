//
//  PinTableViewCell.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-15.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit


class PinTableViewCell: UITableViewCell{

    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
