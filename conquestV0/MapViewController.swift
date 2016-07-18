//
//  FirstViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-11.
//  Copyright © 2016 Nabil. All rights reserved.
//




import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var selectedPin:MKPlacemark? = nil
    var locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var currentUser: User = User(name: "test",password: "test",email: "test")
    var keyForSearchAnnotation: String?
    var pinView: MKPinAnnotationView?
    

    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "buildPin" {
            if let buildPinViewController = segue.destinationViewController as?
                BuildPinViewController {
                buildPinViewController.selectedPin = selectedPin
                buildPinViewController.currentUser = currentUser
                pinView?.canShowCallout = false
        }
    }
}
 
    
    func scaleUIImageToSize(let image: UIImage, let size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    
    
    @IBAction func pinSetterUnwind(sender: UIStoryboardSegue){
        
        populatePins()
        mapView.selectAnnotation(selectedPin!, animated: true)
        
    }
    
    @IBAction func longPressed(sender: UILongPressGestureRecognizer)
    {
        print("longpressed")
        //Different code
    }
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // LONG PRESS FEATURE
        var uilgr = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        uilgr.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(uilgr)

        // BASIC LOCATION MANAGER SETTINGS
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        // SEARCH BAR
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        

        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        populatePins()
        
        mapView.delegate = self
    }
}










extension MapViewController{
    
    //MARK: Helper Functions
    
    func customizePin(){
        performSegueWithIdentifier("buildPin", sender: self)
    }
    
    static func getDirections(selectedPin: MKPlacemark? ){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }
    
    
    func populatePins(){
        let pins = currentUser.pins
        for (_,value) in pins {
            let newPin = MKPointAnnotation()
            newPin.coordinate = value.location
            mapView.addAnnotation(newPin)
        }
        
        mapView.reloadInputViews()
    }
    
    
    func buildKey (annotation: CLLocationCoordinate2D) -> String {
        return String(annotation.latitude) + String(annotation.longitude)
    }

    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
                if placemarks!.count > 0 {
                    let pm = placemarks![0]
                    
                    
                    // not all places have thoroughfare & subThoroughfare so validate those values
                    annotation.title = pm.name //+ ", " + pm.subThoroughfare!
                    if let city = pm.locality, let state = pm.administrativeArea{
                        annotation.subtitle = "\(city) \(state)"
                    }
                    
                    
                    //CONSIDER USING THIS DETAIL FOR THE MAP INSTEAD!
                    //annotation.subtitle = pm.subLocality
                    self.selectedPin = MKPlacemark(placemark: pm)
                    self.mapView.addAnnotation(annotation)
                   
                }
                else {
                    annotation.title = "Unknown Place"
                    self.mapView.addAnnotation(annotation)
                    print("Problem with the data received from geocoder")
                }
                //places.append(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
            })
        }
    }



}







extension MapViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
}






extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        //mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}





extension MapViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orangeColor()
        
        if(currentUser.pins[buildKey(annotation.coordinate)] == nil){
            pinView?.canShowCallout = true // Maybe here?
        }
        else{
            pinView?.canShowCallout = false
        }
        
        
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), forState: .Normal)
        
        
        
        //button.addTarget(self, action: "getDirections", forControlEvents: .TouchUpInside)
        button.addTarget(self, action: "customizePin", forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    
    
// MARK: Deal With Custom Annotations Below
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView){
        
        
        let currentPin = currentUser.pins[buildKey((view.annotation?.coordinate)!)]
       
         if view.annotation is MKUserLocation || currentPin == nil
        {
            // Don't proceed with custom callout
            return
        }
   
        let views = NSBundle.mainBundle().loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views[0] as! CustomCalloutView
        calloutView.center = CGPointMake(view.bounds.size.width / 2, -calloutView.bounds.size.height*0.52)
        
        calloutView.date.text = String(currentPin?.date)
        calloutView.place.text = currentPin?.placeName
        calloutView.image.image = currentPin?.image

        view.addSubview(calloutView)
    
    }



    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
      
        if view.isKindOfClass(MKPinAnnotationView)
        {
            //view.canShowCallout = false
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
}



