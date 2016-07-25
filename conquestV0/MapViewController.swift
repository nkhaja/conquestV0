//
//  FirstViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-11.
//  Copyright © 2016 Nabil. All rights reserved.
//




import UIKit
import MapKit
import Parse
import FBAnnotationClusteringSwift

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}
// UIViewController

class MapViewController: UIViewController, UITabBarDelegate, ENSideMenuDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var parseLoginHelper: ParseLoginHelper!
    let clusteringManager = FBClusteringManager()
    var selectedPin:MKPlacemark? = nil
    var locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var currentUser: PFUser?
    var keyForSearchAnnotation: String?
    var pinView: MKPinAnnotationView?
    var pins: [Pin] = []
    var clusters:[FBAnnotation] = []
    weak var buildPinViewController: BuildPinViewController!

    func setUser(){
        self.currentUser = PFUser.currentUser()
    }
    
    
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "buildPin" {
            if let buildPinViewController = segue.destinationViewController as?
                BuildPinViewController {
                buildPinViewController.selectedPin = selectedPin
                buildPinViewController.currentUser = currentUser!
                //pinView?.canShowCallout = false
        }
    }
}
 


    
    
    
    @IBAction func pinSetterUnwind(sender: UIStoryboardSegue){
        
        pins = MapHelper.populatePins(self.mapView)
        //mapView.selectAnnotation(selectedPin!, animated: true)
    }
    
    @IBAction func longPressed(sender: UILongPressGestureRecognizer)
    {
        print("longpressed")
        //Different code
    }
    
    @IBAction func logOutButton(sender: AnyObject) {
        print("logging out user")
        PFUser.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func toggleSideMenu(sender: AnyObject) {
        toggleSideMenuView()
        print("button pressed")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if (PFUser.currentUser() != nil) {
            
        }
    }
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        buildPinViewController = storyboard.instantiateViewControllerWithIdentifier("BuildPinViewController") as! BuildPinViewController
        // Instantiate BuildPinViewController
        buildPinViewController.delegate = self
        //self.tabBarController?.delegate = self
        setUser()
        pins = MapHelper.populatePins(self.mapView)
        clusters = MapHelper.prepareClustering(pins)

        
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
        let locationSearchTable = storyboard.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
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
        
        mapView.delegate = self

    }
}



extension MapViewController{
    
    //MARK: Helper Functions
    
    func customizePin(){
        performSegueWithIdentifier("buildPin", sender: self)
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
    
    func queryPinAtGeoPoint(annotation: MKAnnotation, completionHandler:([Pin])->Void){
        var currentPins:[Pin] = []
        let pinQuery = PFQuery(className: "Pin")
        pinQuery.whereKey("user", equalTo:PFUser.currentUser()!)
        pinQuery.whereKey("geoLocation", equalTo: PFGeoPoint(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
        
  
        pinQuery.findObjectsInBackgroundWithBlock {(result: [PFObject]?, error: NSError?) -> Void in
            currentPins = result as? [Pin] ?? []
            completionHandler(currentPins)
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        var reuseId = ""
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        else if(annotation.isKindOfClass(FBAnnotationCluster)) {
                reuseId = "Cluster"
                var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
                clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
                return clusterView
        }
        

        reuseId = "pin"
        pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orangeColor()
        
        
        

        //let currentPins = queryPinAtGeoPoint(annotation)
        
         queryPinAtGeoPoint(annotation) { currentPins in
            if(currentPins.count == 0){
                self.pinView?.canShowCallout = true // Maybe here?
            }
            else{
                self.pinView?.canShowCallout = false
            }
        }
        
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), forState: .Normal)
        
        
        
        //button.addTarget(self, action: "getDirections", forControlEvents: .TouchUpInside)
        button.addTarget(self, action: #selector(MapViewController.customizePin), forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    
    
}
    
// MARK: Deal With Custom Annotations Below
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView){
        
        print("didSelectAnnotationCalled")
        
        // let pinHolder = queryPinAtGeoPoint(view.annotation!)
        
         queryPinAtGeoPoint(view.annotation!) { pinHolder in
        
            if view.annotation is MKUserLocation || pinHolder.count == 0
            {
                // Don't proceed with custom callout
                return
            }
            
            let currentPin: Pin? = pinHolder[0]
            let views = NSBundle.mainBundle().loadNibNamed("CustomCalloutView", owner: nil, options: nil)
            let calloutView = views[0] as! CustomCalloutView
            calloutView.center = CGPointMake(view.bounds.size.width / 2, -calloutView.bounds.size.height*0.52)
            
            calloutView.date.text = String(currentPin!.date)
            calloutView.place.text = currentPin!.placeName
            
            let userImageFile = currentPin?["imageFile"] as? PFFile
            userImageFile!.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    let image = UIImage(data:imageData!)
                    calloutView.image.image = image
                }
            }
            view.addSubview(calloutView)
        
        }
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
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        NSOperationQueue().addOperationWithBlock({
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            let scale:Double = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
//            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
        })
    }
    
    
}

// MARK: - BuildPinViewController
extension MapViewController: BuildPinViewControllerDelegate {
    func updatePins() {
        print("update is being called")
        pins = MapHelper.populatePins(self.mapView)

    }
}






