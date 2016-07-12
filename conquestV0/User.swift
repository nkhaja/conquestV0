//
//  User.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-11.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit

class User: NSObject {
    let name:String
    let password: String
    let email: String
    let pins = []
    // Set of Mission
    
    
    init(name: String, password: String, email: String){
        self.name = name
        self.password = password
        self.email = email
    }
    
    

}
