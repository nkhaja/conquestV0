//
//  Pin.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-12.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit
import MapKit
import Parse
class Pin: PFObject, PFSubclassing {
    
    
    @NSManaged var user: PFUser?
    @NSManaged var title: String?
    @NSManaged var placeName: String?
    @NSManaged var geoPoint: PFGeoPoint?
    @NSManaged var date: NSDate
    @NSManaged var details: String?
    @NSManaged var key: String?
    @NSManaged var imageFile: PFFile?
    @NSManaged var tag: PFObject
    

    
    //MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "Pin"
    }
    
     init (place: CLLocationCoordinate2D) { // removed the override from here. 
        super.init()
        user = PFUser.currentUser()
        geoPoint = PFGeoPoint(latitude: place.latitude, longitude: place.longitude)
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    

    
}

extension PFGeoPoint {
    
    func location() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
}
