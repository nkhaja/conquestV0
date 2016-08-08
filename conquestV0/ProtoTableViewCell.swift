//
//  ProtoTableViewCell.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-22.
//  Copyright © 2016 Nabil. All rights reserved.
//

protocol ToggleSwitchDelegate {
    func queryForUserAtRow(indexPath: NSIndexPath)
    func saveState(state:Bool, indexPath: NSIndexPath)
}

import UIKit

class ProtoTableViewCell: UITableViewCell {

    var delegate: ToggleSwitchDelegate? = nil
    var indexPath: NSIndexPath?
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    var state: Bool = false
    
    
    
    @IBAction func switchToggled(sender: UISwitch) {
        delegate?.saveState(toggleSwitch.on, indexPath: self.indexPath!)
        if (self.toggleSwitch.on){
            delegate?.queryForUserAtRow(indexPath!)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.toggleSwitch.on = self.state
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
