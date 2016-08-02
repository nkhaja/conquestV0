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
import KCFloatingActionButton

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}
// UIViewController

class MapViewController: UIViewController, UITabBarDelegate, ENSideMenuDelegate, MapRefreshDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var friendPins: [Pin] = [] {
        didSet{
            buildLocalKeys()
            filterPins()
            
        }
    }
    var pins: [Pin] = [] {
        didSet{
            buildLocalKeys()
            filterPins()
        }
        
    }
    
    
    var localPinDict: NSMutableDictionary = [:]
    var localFriendDict: NSMutableDictionary = [:]
    var localKeys = Set<String>()
    var currentPosition: CLLocation?
    var parseLoginHelper: ParseLoginHelper!
    let clusteringManager = FBClusteringManager()
    var selectedPin:MKPlacemark? = nil
    var locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var currentUser: PFUser?
    var keyForSearchAnnotation: String?
    var pinView: MKAnnotationView? //change
    
    var clusters:[FBAnnotation] = []
    weak var buildPinViewController: BuildPinViewController!
    weak var protoMenuViewController: ProtoMenuViewController!
    
    var zoomToLocation: CLLocationCoordinate2D?
    
    func setUser(){
        self.currentUser = PFUser.currentUser()
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "buildPin" {
            if let buildPinViewController = segue.destinationViewController as?
                BuildPinViewController {
                buildPinViewController.selectedPin = selectedPin
                buildPinViewController.currentUser = currentUser!
            }
        }
            
        else if segue.identifier == "pinList" {
            if let pinViewController = segue.destinationViewController as? PinViewController{
                for p in pins {
                    if (p.image == nil){
                        p.downloadImage()
                    }
                }
                pinViewController.localPins = pins
                pinViewController.friendPins = friendPins
                pinViewController.delegate = self
            }
            
        }
    }
    
    
    @IBAction func findMeButton(sender: UIButton) {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: currentPosition!.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    @IBAction func pinSetterUnwind(sender: UIStoryboardSegue){
    }
    
    
    @IBAction func unWindFromPinTableView (segue: UIStoryboardSegue) {
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: zoomToLocation!, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func longPressed(sender: UILongPressGestureRecognizer)
    {
        print("longpressed")
        //Different code
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if (PFUser.currentUser() != nil) {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Helper Functions
    
    func setupForFloatingButton(){
        let fabManager = KCFABManager.defaultInstance()
        let fab = KCFloatingActionButton()
        
        
        fab.size = 30
        fab.paddingY = 100
        fab.addItem("Find me", icon: UIImage(named: "car")!, handler: { item in
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: self.currentPosition!.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            fab.close()
        })
        
        fab.addItem("Pin Table", icon: UIImage(named: "car")!, handler: { item in
            self.performSegueWithIdentifier("pinList", sender: self)
            fab.close()
        })
        
        
        fab.addItem("Show friend's pins", icon: UIImage(named: "car")!, handler: { item in
            self.toggleSideMenuView()
            fab.close()
        })
        
        
        fab.addItem("Log out", icon: UIImage(named: "car")!, handler: { item in
            PFUser.logOut()
            self.dismissViewControllerAnimated(true, completion: nil)
            fab.close()
        })
        
        fab.addItem("Refresh Map", icon: UIImage(named: "car")!, handler: { item in
            self.refreshMap()
            fab.close()
        })
        
        self.view.addSubview(fab)
    }
    
    
    //MARK: Deal with Pins of User's you are following
    
    func friendsPinsNotificatin(notification: NSNotification) {
        if (notification.userInfo == nil){
            friendPins = []
        }
        
        guard let somePins = notification.userInfo as? [String:[PFObject]], friendUsers = somePins["pin"]
            else {
                return
        }
        
        friendPins = (friendUsers as? [Pin])!
        addFriendPins(friendPins)
        localFriendDict = MapHelper.createDict(friendPins)
        print(friendPins)
    }
    
    func addFriendPins(pins:[Pin]){
        for p in pins{
            let newPin = MKPointAnnotation()
            newPin.coordinate = CLLocationCoordinate2D(latitude: p["geoLocation"].latitude, longitude: p["geoLocation"].longitude)
            dispatch_async(dispatch_get_main_queue(), {
                self.mapView.addAnnotation(newPin)
                self.mapView.reloadInputViews()
                self.reloadInputViews()
            })
        }
    }
    
    func filterPins(){
        let allPins = mapView.annotations
        for a in allPins {
            let key = String(a.coordinate.latitude) + String(a.coordinate.longitude)
            if (!localKeys.contains(key)){
                mapView.removeAnnotation(a)
            }
        }
    }
    
    func buildLocalKeys(){
        let combinedArray = pins + friendPins
        localKeys.removeAll()
        for i in combinedArray {
            let key = String(i["geoLocation"].latitude) + String(i["geoLocation"].longitude)
            localKeys.insert(key)
        }
    }
    
    
    func refreshMap (){
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        MapHelper.populatePins(self.mapView) { (pins) in
            self.pins = pins
            self.clusters = MapHelper.prepareClustering(pins + self.friendPins)
            self.clusteringManager.setAnnotations(self.clusters)
            self.localPinDict = MapHelper.createDict(pins)

        }
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SETUP LOCAL VARIABLES
        setUser()
        setupForFloatingButton()
        
        (self.navigationController as? ENSideMenuNavigationController)?.sideMenu?.delegate = self
        
        
        
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
        
        mapView.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.friendsPinsNotificatin(_:)), name: "friendsPinNotification", object: nil)
        addFriendPins(friendPins)
      
        
        
        if (mapView.annotations.count == 0){
            MapHelper.populatePins(self.mapView) { (pins) in
                self.pins = pins
                self.clusters = MapHelper.prepareClustering(pins + self.friendPins)
                self.clusteringManager.setAnnotations(self.clusters)
                self.localPinDict = MapHelper.createDict(pins)
            }}
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
                    
                    let newCluster = FBAnnotation()
                    newCluster.coordinate = annotation.coordinate
                    newCluster.title = pm.name
                    newCluster.subtitle = annotation.subtitle
                    self.clusteringManager.addAnnotations([newCluster])
                    
                    self.selectedPin = MKPlacemark(placemark: pm)
                    self.mapView.addAnnotation(annotation)
                    
                }
                else {
                    annotation.title = "Unknown Place"
                    self.mapView.addAnnotation(annotation)
                    print("Problem with the data received from geocoder")
                }
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
            currentPosition = location
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
        
        //MARK: Create corresponding FBAnnotation so this pin can be clustered later
        let clusterAnnotation = FBAnnotation()
        clusterAnnotation.coordinate = annotation.coordinate
        clusterAnnotation.title = annotation.title
        clusterAnnotation.subtitle = annotation.subtitle
        
        
        clusteringManager.addAnnotations([clusterAnnotation])
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
        //pinQuery.whereKey("user", equalTo:PFUser.currentUser()!)
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
            
            let smallSquare = CGSize(width: 30, height: 30)
            let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
            button.setBackgroundImage(UIImage(named: "car"), forState: .Normal)
            
            button.addTarget(self, action: #selector(MapViewController.customizePin), forControlEvents: .TouchUpInside)
            clusterView?.leftCalloutAccessoryView = button
            clusterView?.canShowCallout = true
            
            return clusterView
        }
        
        

        pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as MKAnnotationView!
        //pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        
        if pinView == nil {
            pinView = CustomCalloutView(annotation: annotation, reuseIdentifier: "pin")
            pinView?.canShowCallout = false
        } else {
            pinView?.annotation = annotation
        }
        
        
        let searchKey = MapHelper.makeKey(annotation.coordinate)
        if(localPinDict[searchKey] == nil){
            pinView?.image = UIImage(named: "car")
        }
        else{
             pinView?.image = UIImage(named: "first")
        }
        
       //pinView?.image = UIImage(named: "car")
        
        
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), forState: .Normal)
        
        //button.addTarget(self, action: "getDirections", forControlEvents: .TouchUpInside)
        
        button.addTarget(self, action: #selector(MapViewController.customizePin), forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        
        
        //        else if(annotation.isKindOfClass(CustomCalloutView)){
        //            let pinAnnotation = annotation as? MKPinAnnotationView
        //            reuseId = "pin"
        //            pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as MKAnnotationView!
        //
        //            if (pinView == nil){
        //                pinView = pinAnnotation
        //            }
        //
        //            else{
        //
        //                pinView?.annotation = annotation
        //            }
        //        }
        
        
        
        
        queryPinAtGeoPoint(annotation) { currentPins in
            if(currentPins.count == 0){
                self.pinView?.canShowCallout = true // Maybe here?
            }
            else{
                self.pinView?.canShowCallout = false
            }
        }


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
            
            if (view.subviews.count > 0){
                for subview in view.subviews{
                    subview.removeFromSuperview()
                }
                return
            }
            
            
            let currentPin: Pin? = pinHolder[0]
            
            
            
            
            let views = NSBundle.mainBundle().loadNibNamed("CustomCalloutView", owner: nil, options: nil)
            let calloutView = views[0] as! CustomCalloutView
            
            
            let userImageFile = currentPin?["imageFile"] as? PFFile
            userImageFile!.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    let image = UIImage(data:imageData!)
                    currentPin?.image = image
                    calloutView.pinImage.image = image
                }
            }
            
            calloutView.center = CGPointMake(view.bounds.size.width / 2, -calloutView.bounds.size.height*0.52)
            calloutView.date.text = String(currentPin!.date)
            calloutView.place.text = currentPin!.placeName
            
            if(PFUser.currentUser() == currentPin?.user){
                calloutView.owner = true
            }
            else{ calloutView.owner = false }
            
            
            calloutView.location = currentPin?.geoPoint
            calloutView.pinImage.image = currentPin?.image
            
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: (view.annotation?.coordinate)!, span: span)
            mapView.setRegion(region, animated: true)
            
            view.addSubview(calloutView)
        }
    }
    
    
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        
        
        if view.isKindOfClass(CustomCalloutView)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        NSOperationQueue().addOperationWithBlock({
            if(self.mapView.annotations.count < 2){
                return
            }
        
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            let scale:Double = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            self.clusteringManager.displayAnnotations(annotationArray, onMapView: self.mapView)

        })
    }
    
    
}

extension MapViewController: ProtoMenuViewControllerDelegate {
    func makeFriendPins(friendPins: [Pin]) {
        self.friendPins.removeAll()
        self.friendPins = friendPins
        print(friendPins.count)
    }
}




