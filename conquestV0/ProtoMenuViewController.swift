//
//  ProtoMenuViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-22.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit
import Parse

class ProtoMenuViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    var followedUsers: [PFUser]? = [] {
        didSet {
            /**
             the list of following users may be fetched after the tableView has displayed
             cells. In this case, we reload the data to reflect "following" status
             */
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    return (followedUsers?.count)!
    }
    
    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell?{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("sideCell", forIndexPath:  indexPath) as! ProtoTableViewCell
        
        ParseHelper.getFollowingUsersForUser(PFUser.currentUser()!) {
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
        
        cell.userLabel.text = followedUsers![indexPath.row]["username"] as? String

        return cell
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
