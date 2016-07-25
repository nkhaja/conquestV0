//
//  CustomPin.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-20.
//  Copyright © 2016 Nabil. All rights reserved.
//

import Foundation
import MapKit

class CustomPin: NSObject, MKAnnotation{
    
    var title: String?
    var subtitle: String?
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude:Double, longitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
}