//
//  Pin.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-12.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit
import MapKit
class Pin: NSObject {
    var image: UIImage? // set to text button.
    var date: NSDate?
    var user: User
    var location: CLLocationCoordinate2D
    var details: String?
    var title: String?
    var key: String

    
    init(user:User, location: CLLocationCoordinate2D){
        self.user = user
        self.location = location
        self.key = String(location.latitude) + String(location.longitude)
    }
    
    
    func setCurrentDate() -> NSDate{
      return NSDate()
    }
    
//    func setCustomDate() -> NSDate{
//        date = NSDate()
//        
//    }
//    
// figure out how to do custom dates later
    

    func setPinLocation(lat :Double, lon:Double){
        location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
}
