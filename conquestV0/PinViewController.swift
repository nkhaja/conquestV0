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
import MGSwipeTableCell


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
        
        else if (segue.identifier == "edit") {
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

    func setupThisPin(sender: MGSwipeTableCell) {
        self.thisIndexPath = self.tableView.indexPathForCell(sender)!
        self.thisPinIndex = thisIndexPath?.row
        
        if(self.thisIndexPath!.section == 0){
            self.thisPin = localPins[thisPinIndex!]
            self.owner = true
        }
        
        else{
            self.thisPin = self.friendPinDict![sections[thisIndexPath!.section]]![thisIndexPath!.row]
            self.owner = false
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
        //cell.delegate = self
        cell.rightSwipeSettings.transition = MGSwipeTransition.Rotate3D

        
        if(indexPath.section == 0) {
            let rowPin = localPins[indexPath.row]
            self.thisPin = rowPin
            cell.cellPin = rowPin
            cell.pinImage.image = rowPin.image
            cell.titleLabel.text = rowPin.title
            cell.dateLabel.text = rowPin.date
            cell.locationLabel.text = rowPin.placeName
            cell.rightButtons = makeButtons(rowPin, indexPath: indexPath)
        }
        
        else {
            let name = sections[indexPath.section]
            let rowPin = friendPinDict![name]![indexPath.row]
            self.thisPin = rowPin
            cell.cellPin = rowPin
            cell.pinImage.image = rowPin.image
            cell.titleLabel.text = rowPin.title
            cell.dateLabel.text = rowPin.date
            cell.locationLabel.text = rowPin.placeName
            cell.rightButtons = makeButtons(rowPin, indexPath: indexPath)
        }
        
        
        cell.indexPath = indexPath
        return cell 
    }
    
    @IBAction func editPinControllerUnwind(sender: UIStoryboardSegue){
        tableView.reloadData()
    }
    
    func flagPin(user: PFUser, pin: Pin) {
        let flagObject = PFObject(className: "Flag")
        flagObject.setObject(user, forKey: "fromUser")
        flagObject.setObject(pin, forKey: "toPin")
        
        let ACL = PFACL(user: PFUser.currentUser()!)
        ACL.publicReadAccess = true
        flagObject.ACL = ACL
        
        //TODO: add error handling
        flagObject.saveInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        //self.thisIndexPath = indexPath
        //self.thisPinIndex  = indexPath.row
        print("row touched")
    }
    
    
    func makeButtons(pin:Pin, indexPath:NSIndexPath) -> [MGSwipeButton] {

        self.owner = self.thisPin?.user == PFUser.currentUser()

        

    
        let deleteButton = MGSwipeButton(title: "", icon: UIImage(named: "delete-white"),backgroundColor: UIColor.redColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.setupThisPin(sender)
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
                self.tableView.reloadData()
                
            }
            return true
        })
        
        let flagButton = MGSwipeButton(title: "", icon: UIImage(named: "flag-white"),backgroundColor: UIColor.redColor(), callback: {(sender: MGSwipeTableCell!) -> Bool in
            
            self.setupThisPin(sender)
            self.flagPin(PFUser.currentUser()!, pin: self.thisPin!)
            var refreshAlert = UIAlertController(title: "User Flagged", message: "You have flagged this user for inappropriate content", preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            }))
            
            self.presentViewController(refreshAlert, animated: true, completion: nil)
            
            return true
        })
        
        let editButton = MGSwipeButton(title: "", icon: UIImage(named: "edit-white"),backgroundColor: UIColor.yellowColor(), callback: {(sender: MGSwipeTableCell!) -> Bool in
            self.setupThisPin(sender)
            self.performSegueWithIdentifier("edit", sender: self)
            return true
        })
        
        let detailButton = MGSwipeButton(title: "", icon: UIImage(named: "details-white"),backgroundColor: UIColor.blueColor(), callback: { (sender: MGSwipeTableCell!) -> Bool in
            self.setupThisPin(sender)
            self.performSegueWithIdentifier("detail", sender: self)
            return true
        })
        
        let mapButton = MGSwipeButton(title: "", icon: UIImage(named: "seeMap-white"),backgroundColor: UIColor.greenColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
           
            self.setupThisPin(sender)
            
            let lat = self.thisPin!["geoLocation"].latitude
            let lon = self.thisPin!["geoLocation"].longitude
            let point = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
            self.zoomToLocation = point
            self.performSegueWithIdentifier("map", sender: self)

            return true
        })
        
        

        
    
        if self.owner!{
            return [deleteButton, editButton, detailButton, mapButton]
        }
        
        else{
            return [flagButton, detailButton, mapButton]
        }
        
    }
    
    
     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.contentView.backgroundColor = UIColor.clearColor()
        var whiteRoundedView : UIView = UIView(frame: CGRectMake(0, 10, self.view.frame.size.width, 100))
        whiteRoundedView.layer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 3.0
        whiteRoundedView.layer.shadowOffset = CGSizeMake(-1, 1)
        whiteRoundedView.layer.shadowOpacity = 0.5
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
    }
    
    
}
