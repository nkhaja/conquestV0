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
    @NSManaged var date: String?
    @NSManaged var details: String?
    @NSManaged var imageFile: PFFile?
    @NSManaged var annotationId: String
    @NSManaged var ownerName: String?
    
    var image: UIImage?
    

    
    //MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "Pin"
    }
    
    override init(){
        super.init()
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
    
    func changeCoordType() -> CLLocationCoordinate2D{
        let lat = geoPoint?.latitude
        let lon = geoPoint?.longitude
        return CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
    }
  
    func downloadImage() {
        
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                }
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    self.image = image
            }
        }
    }

    
}

extension PFGeoPoint {
    
    func location() -> CLLocationCoordinate2D {
        print(#function, self.latitude, self.longitude)
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
}
