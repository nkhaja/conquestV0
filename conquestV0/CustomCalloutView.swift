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
import Spring

protocol CustomCalloutDelegate {
    func showDetails(detailPin:Pin)
}

class CustomCalloutView: MKAnnotationView {
    
    var owner:Bool = false
    var location: PFGeoPoint?
    var id: String?
    var delegate: CustomCalloutDelegate?
    var thisPin: Pin?
    
    
    

    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var dateLabel: DesignableLabel!
    

    @IBAction func calloutButton(sender: AnyObject) {
        self.delegate!.showDetails(thisPin!)

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
