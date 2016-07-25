//
//  SecondViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-11.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit
import Parse

class PinViewController: UIViewController {
    var pins = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var mapViewController: MapViewController?

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    func getPins(){
    let pinQuery = PFQuery(className: "Pin")
    pinQuery.whereKey("user", equalTo: PFUser.currentUser()!)
    pinQuery.includeKey("user")
    pinQuery.findObjectsInBackgroundWithBlock {(result: [PFObject]?, error: NSError?) -> Void in
        self.pins = result as? [Pin] ?? []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPins()
    }




    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(pins.count)
        return pins.count
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("pinCell", forIndexPath: indexPath) as! PinTableViewCell
        //cell.textLabel?.text = pins[indexPath.item].title
        let thisPin = pins[indexPath.row] as! Pin
        cell.titleLabel.text = thisPin.title
        print(thisPin.title)
        
        return cell
    }

}

