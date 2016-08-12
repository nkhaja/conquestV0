//
//  PinTableViewCell.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-15.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit
import Spring
import MGSwipeTableCell



class PinTableViewCell: MGSwipeTableCell{

    
    @IBOutlet weak var pinImage: DesignableImageView!
    @IBOutlet weak var titleLabel: DesignableLabel!
    @IBOutlet weak var locationLabel: DesignableLabel!
    @IBOutlet weak var dateLabel: DesignableLabel!
    
    var cellPin: Pin?
    var indexPath: NSIndexPath?

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
    

    }

}
