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
    
    static func populatePins(mapView: MKMapView) -> [Pin]{
        var retrievedPins:[Pin] = []
        let pinQuery = PFQuery(className: "Pin")
        pinQuery.whereKey("user", equalTo: PFUser.currentUser()!)
        pinQuery.includeKey("user")
        pinQuery.findObjectsInBackgroundWithBlock {(result: [PFObject]?, error: NSError?) -> Void in
            retrievedPins = result as? [Pin] ?? []
            for p in retrievedPins {
                //print(#function, p)
                //print(#function, p["geoLocation"])
                let newPin = MKPointAnnotation()
                newPin.coordinate = CLLocationCoordinate2D(latitude: p["geoLocation"].latitude, longitude: p["geoLocation"].longitude)
                dispatch_async(dispatch_get_main_queue(), {
                    mapView.addAnnotation(newPin)
                    mapView.reloadInputViews()
                })
            }
            print("closure is finished")
        }
    
        return retrievedPins
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
    
    
    
    
    
    
    
    
//    static func addAnnotation(gestureRecognizer:UIGestureRecognizer, mapView: MKMapView) -> MKPlacemark? {
//        if gestureRecognizer.state == UIGestureRecognizerState.Began {
//            let touchPoint = gestureRecognizer.locationInView(mapView)
//            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = newCoordinates
//            
//            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
//                if error != nil {
//                    print("Reverse geocoder failed with error" + error!.localizedDescription)
//                    return
//                }
//                
//                if placemarks!.count > 0 {
//                    let pm = placemarks![0]
//                    
//                    
//                    // not all places have thoroughfare & subThoroughfare so validate those values
//                    annotation.title = pm.name //+ ", " + pm.subThoroughfare!
//                    if let city = pm.locality, let state = pm.administrativeArea{
//                        annotation.subtitle = "\(city) \(state)"
//                    }
//                    
//                    
//                    //CONSIDER USING THIS DETAIL FOR THE MAP INSTEAD!
//                    //annotation.subtitle = pm.subLocality
//                    var selectedPin = MKPlacemark(placemark: pm)
//                    mapView.addAnnotation(annotation)
//                    return selectedPin
//                    
//                }
//                else {
//                    annotation.title = "Unknown Place"
//                    mapView.addAnnotation(annotation)
//                    print("Problem with the data received from geocoder")
//                    return nil
//                }
//                //places.append(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
//            })
//        }
//    }
    
    
    
    
    
    
}
