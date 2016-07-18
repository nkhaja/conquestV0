//
//  Helper.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-14.
//  Copyright © 2016 Nabil. All rights reserved.
//

import Foundation
import MapKit

class Helper{
    
    static func getDirections(selectedPin: MKPlacemark? ){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }
}