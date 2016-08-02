//
//  ProtoTableViewCell.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-22.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit

class ProtoTableViewCell: UITableViewCell {

    @IBOutlet weak var userLabel: UILabel!
    
    
    
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
