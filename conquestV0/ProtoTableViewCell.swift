//
//  ProtoTableViewCell.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-22.
//  Copyright © 2016 Nabil. All rights reserved.
//

//protocol ToggleSwitchDelegate {
//    func queryForUserAtRow(indexPath: NSIndexPath)
//    func saveState(state:Bool, indexPath: NSIndexPath)
//}

import UIKit

protocol NotifyTableDelegate{
    func notifyTable()
}

class ProtoTableViewCell: UITableViewCell {

    //var delegate: ToggleSwitchDelegate? = nil
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var state: Bool?
    var delegate: NotifyTableDelegate? 
  
    @IBAction func switchToggled(sender: UISwitch) {
        defaults.setBool(toggleSwitch.on, forKey: userLabel.text!)
        delegate?.notifyTable()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    

}
