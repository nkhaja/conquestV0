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
import Spring

protocol MapRefreshDelegate {
    func refreshMap()
}



class PinViewController: UIViewController {
    
    var friendPinDict: [String:[Pin]]?
    var localPins: [Pin] = []
    var friendPins: [Pin] = []
    var zoomToLocation: CLLocationCoordinate2D?
    var thisPin:Pin?
    var thisIndexPath:NSIndexPath?
    var thisPinIndex:Int?
    var updatedPin: Pin?
    var owner:Bool?
    var delegate: MapRefreshDelegate? = nil
    var sections: [String] = ["My Pins"]
 
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var friendArray:[String] = []
        for (name, _) in self.friendPinDict! {
            friendArray.append(name)
        }
        
        let sortedFriends = friendArray.sort { $0 < $1}
        self.sections = sections + sortedFriends
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController() && delegate != nil ){
            delegate!.refreshMap()
        }
    }
    
     override func  prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detail"{
            if let detailViewController = segue.destinationViewController as? DetailViewController {
                detailViewController.thisPin = self.thisPin

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
        
        if indexPath.section == 0{
            self.thisPin = self.localPins[indexPath.row]
        }
        else{
            self.thisPin = self.friendPinDict![sections[indexPath.section]]![indexPath.row]
        }
        
        
        self.thisPin = self.localPins[indexPath.row]
        
        let map = UITableViewRowAction(style: .Normal, title: "           ") { action, index in
            let lat = self.thisPin!["geoLocation"].latitude
            let lon = self.thisPin!["geoLocation"].longitude
            let point = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
            
            self.zoomToLocation = point
            self.performSegueWithIdentifier("map", sender: self)
            
        }
        map.backgroundColor = UIColor.brownColor()
        
        let detail = UITableViewRowAction(style: .Normal, title: "           ") { action, index in
            self.performSegueWithIdentifier("detail", sender: self)
        }
        
        detail.backgroundColor = UIColor.orangeColor()
        
        let edit = UITableViewRowAction(style: .Normal, title: "           ") { action, index in
            self.thisIndexPath = indexPath
            self.thisPinIndex = indexPath.row
            self.performSegueWithIdentifier("edit", sender: self)
        }
        edit.backgroundColor = UIColor.blueColor()
        
        
        let delete = UITableViewRowAction(style: .Normal, title: "           ") { action, index in
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
        
        delete.backgroundColor = UIColor.redColor()
        
        
        if indexPath.section == 0{
            return [map, detail, edit, delete]
        }
        
        else{
             return [map, detail]
        }
        
    }
    
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {

    
        return sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) { return localPins.count }
        else {              return (friendPinDict![sections[section]]?.count)! }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("pinCell", forIndexPath: indexPath) as! PinTableViewCell
        
        if(indexPath.section == 0) {
            let rowPin = localPins[indexPath.row]
            cell.pinImage.image = rowPin.image
            cell.titleLabel.text = rowPin.title
            cell.dateLabel.text = rowPin.date
        }
        
        else {
            
            let name = sections[indexPath.section]
            let rowPin = friendPinDict![name]![indexPath.row]
            cell.pinImage.image = rowPin.image
            cell.titleLabel.text = rowPin.title
            cell.dateLabel.text = rowPin.date
        }
        
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
