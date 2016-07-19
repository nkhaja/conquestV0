//
//  User.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-11.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit
import Parse

class User: PFObject, PFSubclassing {
    
    @NSManaged var username: String?
    @NSManaged var password: String?
    @NSManaged var email: String?
    @NSManaged var pins: NSMutableArray
    //@NSManaged var pins: NSMutableArray

    // Set of Mission
    
    
    //MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "User"
    }
    
    
    init(username: String){
        super.init()
        self.username = username
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    
    func addPin(pin:Pin){
        pins.addObject(pin)
        pin.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("object saved")
            } else {
                print("error")
            }

        }
        
        
        
    }

}
