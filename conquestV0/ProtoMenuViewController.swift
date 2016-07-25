//
//  ProtoMenuViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-22.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit
import Parse

class ProtoMenuViewController: UITableViewController {

    
    //@IBOutlet weak var tableView: UITableView!
    var followedUsers: [PFUser]? = [] {
        didSet {
            /**
             the list of following users may be fetched after the tableView has displayed
             cells. In this case, we reload the data to reflect "following" status
             */
            //tableView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(ProtoTableViewCell.self, forCellReuseIdentifier: "sideCell")
        tableView.backgroundColor = UIColor.clearColor()
    
        setupTableView()
//        getFollowingUsers()
        
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
    
    func setupTableView() {
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0)
        tableView.scrollsToTop = false
        tableView.separatorStyle = .SingleLine
        tableView.backgroundColor = UIColor.clearColor()
        self.clearsSelectionOnViewWillAppear = false
    }
    
//    func getFollowingUsers(){
//        let followQuery = PFQuery(className: "Follow")
//        followQuery.whereKey("toUser", equalTo: PFUser.currentUser()!)
//        
//        let userQuery = PFQuery(className: "User")
//        userQuery.whereKey("objectId", matchesKey: "fromUser", inQuery: followQuery)
//        
//        userQuery.findObjectsInBackgroundWithBlock {(result: [PFObject]?, error: NSError?) -> Void in
//            self.followedUsers = result as? [PFUser] ?? []
//            //completionHandler(followedUsers)
//        
//        }
//    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    return (followedUsers?.count) ?? 0 
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("sideCell", forIndexPath:  indexPath) as? ProtoTableViewCell
        
        if (cell == nil){
             cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "sideCell") as? ProtoTableViewCell
        }
        
            
        //.dequeueReusableCellWithIdentifier("sideCell", forIndexPath:  indexPath) as! ProtoTableViewCell
        
        
        cell!.textLabel?.text = followedUsers![indexPath.row]["username"] as? String
        cell!.textLabel?.textColor = UIColor.greenColor()
        cell!.backgroundColor = UIColor.clearColor()
        
        
        return cell!
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
