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

class ProtoMenuViewController: UIViewController {
    
//    var delegate: ProtoMenuViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    weak var mapViewController: MapViewController!

    var retrievedPins:[Pin] = [] {
        didSet {
    self.tableView.reloadData()
        }
    }

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
    
    var pinsOfFollowedUsers: [Pin] = [] {
        didSet{
    
        }
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.registerClass(ProtoTableViewCell.self, forCellReuseIdentifier: "sideCell")
        self.tableView.backgroundColor = UIColor.clearColor()
        
        
        
        setupTableView()
        
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
    
    


    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return (followedUsers?.count) ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("sideCell", forIndexPath:  indexPath) as! ProtoTableViewCell
        //cell.toggleSwitch.setOn(false, animated: false)
        
 
        cell.userLabel.text = followedUsers![indexPath.row]["username"] as? String
        cell.backgroundColor = UIColor.clearColor()
        
        if cell.toggleSwitch.on {
            let pinQuery = PFQuery(className: "Pin")
            let thisUser = followedUsers![indexPath.row] as PFUser
            


            pinQuery.whereKey("user", equalTo: thisUser)
            queries.append(pinQuery)
        }
        
        
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
    
    func getPinsOfSelectedUsers() {
        
        if( queries.count > 0){
            let combinedQuery = PFQuery.orQueryWithSubqueries(queries)
            combinedQuery.findObjectsInBackgroundWithBlock {(result: [PFObject]?, error: NSError?) -> Void in
                //            self.retrievedPins = result as? [Pin] ?? []
                if let result = result {
                    NSNotificationCenter.defaultCenter().postNotificationName("friendsPinNotification", object: self, userInfo: ["pin":result])
                    // ADD DELEGATE CALL FOR VIEW WILL APPEAR HERE
                }
            }
        }
        
        else{
            NSNotificationCenter.defaultCenter().postNotificationName("friendsPinNotification", object: self, userInfo: nil)
        }
       queries.removeAll()  
    }
    
    @IBAction func setFriendPinsButton(sender: AnyObject) {
        self.tableView.reloadData()
        getPinsOfSelectedUsers()
       
    }
    

    
}
