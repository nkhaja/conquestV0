//
//  MapViewHelper.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-21.
//  Copyright © 2016 Nabil. All rights reserved.
//

import Foundation
import MapKit
import Parse
import FBAnnotationClusteringSwift

class MapHelper{
    
    static func populatePins(mapView: MKMapView, callBack: ([Pin]) -> Void ) {
        mapView.removeAnnotations(mapView.annotations)
        let pinQuery = PFQuery(className: "Pin")
        pinQuery.whereKey("user", equalTo: PFUser.currentUser()!)
        pinQuery.includeKey("user")
        pinQuery.findObjectsInBackgroundWithBlock {(result: [PFObject]?, error: NSError?) -> Void in
            let retrievedPins = result as? [Pin] ?? []
            for p in retrievedPins {
                let newPin = MKPointAnnotation()
                newPin.coordinate = CLLocationCoordinate2D(latitude: p["geoLocation"].latitude, longitude: p["geoLocation"].longitude)
                mapView.addAnnotation(newPin)
                mapView.reloadInputViews()
            }
            
            print("closure is finished")
            callBack(retrievedPins)
        }
    
    }
    
    
    static func prepareClustering(pins:[Pin]) -> [FBAnnotation]{
        var clusters: [FBAnnotation] = []
        for p in pins{
            let clusterItem = FBAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: p["geoLocation"].latitude, longitude: p["geoLocation"].longitude)
            clusterItem.coordinate = coordinate
            clusters.append(clusterItem)
        }
        return clusters
    }
    
    
    static func scaleUIImageToSize(let image: UIImage, let size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    
    static func getDirections(selectedPin: MKPlacemark? ){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }
    
    static func createDict(pins: [Pin]) -> NSMutableDictionary{
        var newDict: NSMutableDictionary = [:]
        for p in pins{
            let latKey = String(p["geoLocation"].latitude)
            let lonKey = String(p["geoLocation"].longitude)
            let thisKey = latKey + lonKey
            newDict[thisKey] = p
        }
        return newDict
    }
    
    static func makeKey(coordinate:CLLocationCoordinate2D) -> String {
        let lat = String (coordinate.latitude)
        let lon = String (coordinate.longitude)
        return lat + lon
    }
  
    
}
