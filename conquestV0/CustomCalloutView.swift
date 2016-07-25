//
//  CustomCalloutView.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-13.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit

class CustomCalloutView: UIView {
    

    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var with: UILabel!
    
    
    @IBAction func testButton(sender: AnyObject) {
        
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
