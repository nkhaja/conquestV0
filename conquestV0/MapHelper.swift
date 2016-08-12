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
            
            callBack(retrievedPins)
        }
    }
    
    static func populateFriendPins(mapView: MKMapView, friendPins: [Pin]){
        for p in friendPins {
            let newPin = MKPointAnnotation()
            newPin.coordinate = CLLocationCoordinate2D(latitude: p["geoLocation"].latitude, longitude: p["geoLocation"].longitude)
            mapView.addAnnotation(newPin)
            mapView.reloadInputViews()
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
    
    static func createDict(pins: [Pin]) -> [String:Pin]{
        var newDict: [String:Pin] = [:]
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
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func nameKeyDict(pins: [Pin]) -> [String:[Pin]]{
        var newDict: [String:[Pin]] = [:]
        for p in pins{
            var arrayForUser: [Pin] = []
            let name = p.ownerName!
            if newDict[name] == nil{
                arrayForUser.append(p)
                newDict[name] = arrayForUser
            }
            
            else {
                newDict[name]?.append(p)
            }
        }
        return newDict
    }
}


