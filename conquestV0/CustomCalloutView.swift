//
//  CustomCalloutView.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-13.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit
import MapKit
import Parse
class CustomCalloutView: MKAnnotationView {
    
    var owner:Bool = false
    var location: PFGeoPoint?
    var id: String?
    
    @IBOutlet weak var pinImage: UIImageView!
    
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var with: UILabel!
    
    
    @IBAction func testButton(sender: AnyObject) {
 
//        else {
//            let message = "You don't own this pin! \n remove this pin using options menu"
//            let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
//            //self.presentViewController(alert, animated: true, completion: nil)
//        }
   
        
      
        superview?.removeFromSuperview().self
        print("button tapped")
    }
    
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        if hitView != nil {
            self.superview?.bringSubviewToFront(hitView!)
        }
        return hitView
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let rect = self.bounds
        var isInside = CGRectContainsPoint(rect, point )
        if !isInside {
            
            for view in self.subviews {
                isInside = CGRectContainsPoint(view.frame, point)
                if isInside {
                    break
                }
            }
        }
        
        return isInside
    }
    
}
