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

class MapViewController: UIViewController, MapRefreshDelegate, CustomCalloutDelegate {
    
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
    
   
    
    
    var localPinDict: [String:Pin] = [:]
    var localFriendDict: [String:Pin] = [:]
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
    var usersBeingFollowed: [PFUser]?
    var detailPin: Pin?
    var allowClustering: Bool = false
    
    func setUser(){
        self.currentUser = PFUser.currentUser()
    }
    
    
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
                pinViewController.localPins = pins
                pinViewController.friendPins = friendPins
                pinViewController.friendPinDict = MapHelper.nameKeyDict(friendPins)
                pinViewController.delegate = self
            }
            
        }
        
        else if segue.identifier == "addFriends" {
            if let friendSearchViewController = segue.destinationViewController as? FriendSearchViewController{
            }
        }
        
        else if segue.identifier == "addFriends" {
            if let protoMenuViewController = segue.destinationViewController as? ProtoMenuViewController{
            }
        }
        
        else if segue.identifier == "showDetails" {
            if let detailViewController = segue.destinationViewController as? DetailViewController{
                detailViewController.thisPin = detailPin
            }
        }
    }
    
    
    @IBAction func refreshButton(sender: AnyObject){
        refreshMap()
    }
    
    @IBAction func zoomOutButton(sender: AnyObject) {
        var region = mapView.region
        region.span.latitudeDelta = min(region.span.latitudeDelta * 2, 180)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 2, 180)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    
    @IBAction func findMeButton(sender: UIButton) {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: currentPosition!.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    @IBAction func pinSetterUnwind(sender: UIStoryboardSegue){
        refreshMap()
    }
    
    
    @IBAction func unWindFromPinTableView (segue: UIStoryboardSegue) {
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center: zoomToLocation!, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func unWindFromProtoMenu (segue: UIStoryboardSegue) {
        refreshMap()
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
        
        let fabRight = KCFloatingActionButton()
        let fabRightImage = UIImage(named: "connect-2")
        fabRight.openAnimationType = .SlideUp
        fabRight.buttonColor = MapHelper.hexStringToUIColor("#36B0FF")
        fabRightImage!.drawInRect(CGRect(x: 25, y: 25, width: 25, height: 25))
        fabRight.buttonImage = fabRightImage
        
     
        fabRight.itemButtonColor = MapHelper.hexStringToUIColor("#36B0FF")
        fabRight.size = 40
        fabRight.itemSize = 40
        fabRight.paddingX = 20
        fabRight.friendlyTap = false
 
        ///////////
        
        let fabLeft = KCFloatingActionButton()
        let fabLeftImage = UIImage(named: "settings-3")
        fabLeft.openAnimationType = .SlideUp
        fabLeft.buttonColor = MapHelper.hexStringToUIColor("#36B0FF")
        fabLeftImage?.drawInRect(CGRect(x: 25, y: 25, width: 25, height: 25))
        
        
        fabLeft.buttonImage = fabLeftImage //UIImage(named: "settings")
        fabLeft.itemButtonColor = MapHelper.hexStringToUIColor("#36B0FF")
        fabLeft.size = 40
        fabLeft.itemSize = 40
        fabLeft.paddingX = UIScreen.mainScreen().bounds.width - 60
        fabLeft.friendlyTap = false
    
        
        ////////////////// RIGHT FAB ITEMS //////////////////////////
        
        fabRight.addItem("My Pins", icon: UIImage(named: "placeholder")!, handler: { item in
            self.performSegueWithIdentifier("pinList", sender: self)
            fabRight.close()
        })
        
        
        fabRight.addItem("Followees", icon: UIImage(named: "symbol")!, handler: { item in
            self.performSegueWithIdentifier("viewFriendPins", sender: self)
            fabRight.close()
        })
        
        
        fabRight.addItem("Add friends", icon: UIImage(named: "add-white")!, handler: { item in
            self.performSegueWithIdentifier("addFriends", sender: self)
            fabRight.close()
        })
        
        fabRight.addItem("Log out", icon: UIImage(named: "man-and-opened-exit-door")!, handler: { item in
            PFUser.logOut()
            self.dismissViewControllerAnimated(true, completion: nil)
            fabRight.close()
        })
        

    
        ///////////////// LEFT FAB ITEMS /////////////////////////////
        
        fabLeft.addItem("Find Me", icon: UIImage(named: "weapon-crosshair")!, handler: { item in
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: self.currentPosition!.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            fabLeft.close()
        })
        
        
        fabLeft.addItem(" Cluster", icon: UIImage(named: "arrow-cluster")!, handler: { item in
            self.allowClustering = !self.allowClustering
            fabLeft.close()
        })
        
        
       fabLeft.addItem("  Maps", icon: UIImage(named: "seeMap-white")!, handler: { item in
            
            var mapChangeAlert = UIAlertController(title:"Change Map", message: "Select Map Type", preferredStyle: UIAlertControllerStyle.Alert)
            
            mapChangeAlert.addAction(UIAlertAction(title: "Standard", style: .Default, handler: { (action: UIAlertAction!) in
                self.mapView.mapType = .Standard
            }))
            
            mapChangeAlert.addAction(UIAlertAction(title: "Hybrid", style: .Default, handler: { (action: UIAlertAction!) in
                self.mapView.mapType = .Hybrid
            }))
            
            mapChangeAlert.addAction(UIAlertAction(title: "Satellite Flyover", style: .Default, handler: { (action: UIAlertAction!) in
                self.mapView.mapType = .SatelliteFlyover
            }))
            
            mapChangeAlert.addAction(UIAlertAction(title: "Hybrid Flyover", style: .Default, handler: { (action: UIAlertAction!) in
                self.mapView.mapType = .HybridFlyover
            }))
            
            self.presentViewController(mapChangeAlert, animated: true, completion: nil)
            
            fabLeft.close()
        })
        
        fabLeft.addItem("Refresh", icon: UIImage(named: "refresh-button")!, handler: { item in
            self.refreshMap()
            fabLeft.close()
        })
        
        for i in 0..<fabLeft.items.count{
            var title = fabLeft.items[i].titleLabel
            title.frame.origin.x = title.frame.size.width - 10
        }
        
         self.view.addSubview(fabRight)
         self.view.addSubview(fabLeft)
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
        
        MapHelper.populateFriendPins(self.mapView, friendPins: friendPins)
        
        MapHelper.populatePins(self.mapView) { (pins) in
            self.pins = pins
            for p in pins {
                if (p.image == nil){
                    p.downloadImage()}}
            self.clusters = MapHelper.prepareClustering(pins + self.friendPins)
            self.clusteringManager.setAnnotations(self.clusters)
            self.localPinDict = MapHelper.createDict(pins)
            self.localFriendDict = MapHelper.createDict(self.friendPins)

        }
    }
    
    func showDetails(detailPin: Pin){
        self.detailPin = detailPin
        performSegueWithIdentifier("showDetails", sender: self)
        
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsBuildings = true
        self.mapView.mapType = .Standard
        
        let mapCamera = MKMapCamera()
        
        mapCamera.pitch = 45
        mapCamera.altitude = 500
        mapCamera.heading = 45
        
        // Set MKmapView camera property
        self.mapView.camera = mapCamera
        
        self.mapView.delegate!.mapView!(self.mapView, regionDidChangeAnimated: true)
        
        //SETUP LOCAL VARIABLES
        setUser()
        setupForFloatingButton()
        
        //(self.navigationController as? ENSideMenuNavigationController)?.sideMenu?.delegate = self
        
        
        
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
        //searchBar.backgroundColor = MapHelper.hexStringToUIColor("#00a774")
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
                for p in pins {
                    if (p.image == nil){
                        p.downloadImage()
                    }
                }
            }}
    
        //Update the current List of Friends 
        
        let friendQuery = PFQuery(className: "Follow")
        friendQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        friendQuery.findObjectsInBackgroundWithBlock {(result: [PFObject]?, error: NSError?) -> Void in
            self.usersBeingFollowed = result as? [PFUser] ?? []
        }
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
            clusterView?.canShowCallout = false
            
            return clusterView
        }
        
        

        pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as MKAnnotationView!
        
        
        if pinView == nil {
            pinView = CustomCalloutView(annotation: annotation, reuseIdentifier: "pin")
            pinView?.canShowCallout = false
        } else {
            pinView?.annotation = annotation
        }
        
        
        let searchKey = MapHelper.makeKey(annotation.coordinate)
        
        if (localPinDict[searchKey] != nil){
            pinView?.image = UIImage(named: localPinDict[searchKey]!.annotationId)
        }
        
        else if (localFriendDict[searchKey] != nil){
            pinView?.image = UIImage(named: (localFriendDict[searchKey]?.annotationId)!)
        }
        
        else{
            
            pinView?.image = UIImage(named: "defaultPin")
        }
        
        
        let smallSquare = CGSize(width: pinView?.frame.width ?? 0, height: pinView?.frame.height ?? 0)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setImage(UIImage(named: "defaultPin"), forState: .Normal)
        button.contentMode = .ScaleAspectFit
        
        //button.setBackgroundImage(UIImage(named: "defaultPin"), forState: .Normal)
        
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
                self.pinView?.canShowCallout = true // Check that I don't already have a pin here.
            }
            else{
                self.pinView?.canShowCallout = false
            }
        }
        
        return pinView
    }
    
    // MARK: Deal With Custom Annotations Below
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView){
        
        print("selected")
        
        // let pinHolder = queryPinAtGeoPoint(view.annotation!)
        
        queryPinAtGeoPoint(view.annotation!) { pinHolder in
            
            if view.annotation is MKUserLocation || pinHolder.count == 0
            { return // Don't proceed with custom callout
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
            
            if(PFUser.currentUser() == currentPin?.user){
                calloutView.owner = true
            }
            
            else{
                calloutView.owner = false
            }
            
            calloutView.center = CGPointMake(view.bounds.size.width / 2, -calloutView.bounds.size.height*0.52)
            calloutView.delegate = self
            calloutView.thisPin = currentPin!
            calloutView.pinImage.image = currentPin?.image
            calloutView.dateLabel.text = currentPin?.date
            calloutView.ownerLabel.text = currentPin?.ownerName
            
            calloutView.pinImage.animation = "slideUp"
            calloutView.pinImage.curve = "linear"
            calloutView.pinImage.duration = 1.5
            calloutView.pinImage.animate()
            
            calloutView.dateLabel.animation = "slideUp"
            calloutView.dateLabel.curve = "linear"
            calloutView.dateLabel.duration = 1.5
            calloutView.dateLabel.animate()
            
            calloutView.ownerLabel.animation = "slideUp"
            calloutView.ownerLabel.curve = "linear"
            calloutView.ownerLabel.duration = 1.5
            calloutView.ownerLabel.animate()
            

            
            
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: (view.annotation?.coordinate)!, span: span)
            mapView.setRegion(region, animated: true)
            
            view.addSubview(calloutView)
        }
    }
    
    
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
    
        if view.isKindOfClass(CustomCalloutView){
            for subview in view.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        NSOperationQueue().addOperationWithBlock({
        
            if (self.allowClustering) {
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            let scale:Double = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            self.clusteringManager.displayAnnotations(annotationArray, onMapView: self.mapView)
            
            }

        
        })
    }
}

extension MapViewController: ProtoMenuViewControllerDelegate {
    func makeFriendPins(friendPins: [Pin]) {
        self.friendPins.removeAll()
        self.friendPins = friendPins
    }
}




