//
//  SecondViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-11.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit
import Parse
import MapKit

class PinViewController: UIViewController {

    var localPins: [Pin] = []
    var friendPins: [Pin] = []
    var zoomToLocation: CLLocationCoordinate2D?
    var thisPin:Pin?
    var thisIndexPath:NSIndexPath?
    var thisPinIndex:Int?
    var updatedPin: Pin?
    var owner:Bool?
 
    

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()){
            
        
        }
    }
    
     override func  prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detail"{
            if let detailViewController = segue.destinationViewController as? DetailViewController {
                detailViewController.currentTitle = self.thisPin!.title
                detailViewController.currentDate = String(self.thisPin!.date)
                detailViewController.currentLocation = self.thisPin!.placeName
                detailViewController.currentDescription = self.thisPin!.details
                //detailViewController.currentImage = self.thisPin!.imageFile
            }
        }
        
        else if ( segue.identifier == "edit") {
            if let editPinViewController = segue.destinationViewController as? EditPinViewController{
                editPinViewController.thisPinIndex = self.thisPinIndex!
                editPinViewController.thisPin = self.thisPin
                editPinViewController.imageHolder = thisPin?.image
            }
        }
        
        else if (segue.identifier == "map"){
            if let mapViewController = segue.destinationViewController as? MapViewController {
                mapViewController.zoomToLocation = zoomToLocation
            }
        }
    }



    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        self.thisPin = self.localPins[indexPath.row]
        
        let map = UITableViewRowAction(style: .Normal, title: "Map") { action, index in
            let lat = self.thisPin!["geoLocation"].latitude
            let lon = self.thisPin!["geoLocation"].longitude
            let point = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
            
            self.zoomToLocation = point
            self.performSegueWithIdentifier("map", sender: self)
        }
        map.backgroundColor = UIColor.lightGrayColor()
        
        let detail = UITableViewRowAction(style: .Normal, title: "details") { action, index in
            self.performSegueWithIdentifier("detail", sender: self)
        }
        
        detail.backgroundColor = UIColor.orangeColor()
        
        let edit = UITableViewRowAction(style: .Normal, title: "edit") { action, index in
            self.thisIndexPath = indexPath
            self.thisPinIndex = indexPath.row
            self.performSegueWithIdentifier("edit", sender: self)
        }
        edit.backgroundColor = UIColor.blueColor()
        
        
        let delete = UITableViewRowAction(style: .Normal, title: "delete") { action, index in
            self.owner = self.thisPin?.user == PFUser.currentUser()
            if(self.owner!){
                let deleteQuery = Pin.query()
                deleteQuery?.whereKey("user", equalTo: PFUser.currentUser()!)
                deleteQuery?.whereKey("geoLocation", equalTo: self.thisPin!["geoLocation"])
                deleteQuery!.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    if error == nil {
                        if let objects = objects as? [Pin] {
                            for object in objects {
                                object.deleteInBackground()
                            }
                        }
                    } else {
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                }
            self.thisPinIndex = self.localPins.indexOf(self.thisPin!)
            self.localPins.removeAtIndex(self.thisPinIndex!)
            tableView.reloadData()
            }
        }
        
        delete.backgroundColor = UIColor.purpleColor()
        
        return [map, detail, edit, delete]
        }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localPins.count
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("pinCell", forIndexPath: indexPath) as! PinTableViewCell
        let rowPin = localPins[indexPath.row]
        
        cell.pinImage.image = rowPin.image
        

    
        cell.titleLabel.text = rowPin.title
        cell.dateLabel.text = String(rowPin.date)
        return cell 
    }
    
    @IBAction func editPinControllerUnwind(sender: UIStoryboardSegue){
        tableView.reloadData()
    }

    
    
    
    
    
    //MARK: Accessories for functionality ///
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    

}
