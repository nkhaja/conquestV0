//
//  ProtoMenuViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-22.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit
import Parse
import MapKit

protocol ProtoMenuViewControllerDelegate {
    func makeFriendPins(friendPins: [Pin])
}

  //, ToggleSwitchDelegate

class ProtoMenuViewController: UIViewController, NotifyTableDelegate{
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var tableView: UITableView!
    weak var mapViewController: MapViewController!

    var retrievedPins:[Pin] = [] {
        didSet {
    self.tableView.reloadData()
        }
    }

    
    
    
    var states: [String:Bool] = [:]
    
    var followedUsers: [PFUser]? = [] {
        didSet {
            /**
             the list of following users may be fetched after the tableView has displayed
             cells. In this case, we reload the data to reflect "following" status
             */
            self.tableView.reloadData()
        }
    }
    
    var queries: [PFQuery] = []{
        didSet{
            
        }
    }
    
    var pinsOfFollowedUsers: [Pin]? {
        didSet{
    
        }
    
    }
    
    func notifyTable() {
        queries.removeAll()
        self.tableView.reloadData()
    }
    
    func saveState(state: Bool, indexPath: NSIndexPath) {
        states[String(indexPath)] = state
    }
    
    func queryForUserAtRow(indexPath: NSIndexPath){
        //let cell = tableView.cellForRowAtIndexPath(indexPath)
        let followQuery = PFQuery(className: "Pin")
        let thisUser = followedUsers![indexPath.row] as PFUser
        followQuery.whereKey("user", equalTo: thisUser)
        queries.append(followQuery)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.clearColor()
        //setupTableView()

        ParseHelper.getInfoForSideMenu(PFUser.currentUser()!) {
            (results: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            let relations = results ?? []
            // use map to extract the User from a Follow object
            self.followedUsers = relations.map {
                $0.objectForKey(ParseHelper.ParseFollowToUser) as! PFUser
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    


    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return (followedUsers?.count) ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("sideCell", forIndexPath:  indexPath) as! ProtoTableViewCell
        let followee = followedUsers![indexPath.row]["username"] as? String
        let toggleState: Bool? = defaults.boolForKey(followee!)
        
        if let toggleState = toggleState {
            cell.toggleSwitch.on = toggleState
        }
        
            
        else{
            cell.toggleSwitch.on = false
        }
        
        if (cell.toggleSwitch.on){
            queryForUserAtRow(indexPath)
        }
        
        
        cell.userLabel.text = followee
        cell.backgroundColor = UIColor.clearColor()
        cell.delegate = self
        return cell
    }
    
    func setupTableView() {
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0)
        tableView.scrollsToTop = false
        tableView.separatorStyle = .SingleLine
        tableView.backgroundColor = UIColor.clearColor()
        //self.clearsSelectionOnViewWillAppear = false
    }
    
    func getPinsOfSelectedUsers(callBack: ([Pin]) -> Void) {
        
        if( queries.count > 0){
            let combinedQuery = PFQuery.orQueryWithSubqueries(queries)
            combinedQuery.findObjectsInBackgroundWithBlock {(result: [PFObject]?, error: NSError?) -> Void in
                if let result = result as? [Pin] {
                    print("I need to get here")
                    callBack(result)
                }
                
                
            }
        }
        
        else {
            callBack([])
        }
        

        
       queries.removeAll()  
    }
    
    @IBAction func setFriendPinsButton(sender: AnyObject) {
}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "exitFromProtoToMap"{
            getPinsOfSelectedUsers() { (pins) in
                self.pinsOfFollowedUsers = pins
                //self.performSegueWithIdentifier("exitFromProtoToMap", sender: self)
                if let mapViewController = segue.destinationViewController as? MapViewController{
                    mapViewController.friendPins = self.pinsOfFollowedUsers!
                    mapViewController.refreshMap()
                }
            }
        }
    }
}
