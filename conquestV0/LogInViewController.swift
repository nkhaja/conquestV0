//
//  LoginViewController.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-21.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit

import MapKit
import FBSDKCoreKit
import Parse
import ParseUI
import ParseFacebookUtilsV4


class LogInViewController : PFLogInViewController {
    
    var backgroundImage : UIImageView!;
    var viewsToAnimate: [UIView!]!;
    var viewsFinalYPosition : [CGFloat]!;
    
    
    override func viewWillAppear(animated: Bool) {
        let user = PFUser.currentUser()
        if(user != nil){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let controller = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            
            let top = UIApplication.sharedApplication().keyWindow?.rootViewController
            top?.presentViewController(controller, animated: true, completion: nil)
            
            //self.presentViewController(controller, animated: true, completion: nil)
           // self.navigationController?.pushViewController(controller, animated: true)
        
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set our custom background image
        backgroundImage = UIImageView(image: UIImage(named: "testPic"))
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        logInView!.insertSubview(backgroundImage, atIndex: 0)
        
        // remove the parse Logo
        let logo = UILabel()
        logo.text = "Memory Map"
        logo.textColor = UIColor.whiteColor()
        logo.font = UIFont(name: "Pacifico", size: 70)
        logo.shadowColor = UIColor.lightGrayColor()
        logo.shadowOffset = CGSizeMake(2, 2)
        logInView?.logo = logo
        
        // set forgotten password button to white
        logInView?.passwordForgottenButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        // make the background of the login button pop more
        logInView?.logInButton?.setBackgroundImage(nil, forState: .Normal)
        logInView?.logInButton?.backgroundColor = UIColor(red: 52/255, green: 191/255, blue: 73/255, alpha: 1)
        
        // make the buttons classier
        //customizeButton(logInView?.facebookButton!)
        //customizeButton(logInView?.twitterButton!)
        customizeButton(logInView?.signUpButton!)
        
        // create an array of all the views we want to animate in when we launch
        // the screen
        viewsToAnimate = [self.logInView?.usernameField, self.logInView?.passwordField, self.logInView?.logInButton, self.logInView?.passwordForgottenButton, self.logInView?.signUpButton, self.logInView?.logo]
        // missing the Twitter button above //  self.logInView?.twitterButton,
        // Missing FaceBook button above // self.logInView?.facebookButton,
        
    }
    
    func customizeButton(button: UIButton!) {
        button.setBackgroundImage(nil, forState: .Normal)
        button.backgroundColor = UIColor.clearColor()
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        backgroundImage.frame = CGRectMake( 0,  0,  logInView!.frame.width,  logInView!.frame.height)
        
        // position logo at top with larger frame
        logInView!.logo!.sizeToFit()
        let logoFrame = logInView!.logo!.frame
        logInView!.logo!.frame = CGRectMake(logoFrame.origin.x, logInView!.usernameField!.frame.origin.y - logoFrame.height - 16, logInView!.frame.width,  logoFrame.height)
        
        // We to position all the views off the bottom of the screen
        // and then make them rise back to where they should be
        // so we track their final position in an array
        // but change their frame so they are shifted downwards off the screen
        viewsFinalYPosition = [CGFloat]();
        for viewToAnimate in viewsToAnimate {
            let currentFrame = viewToAnimate.frame
            viewsFinalYPosition.append(currentFrame.origin.y)
            viewToAnimate.frame = CGRectMake(currentFrame.origin.x, self.view.frame.height + currentFrame.origin.y, currentFrame.width, currentFrame.height)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Now we'll animate all our views back into view
        // and, using the final position we stored, we'll
        // reset them to where they should be
        if viewsFinalYPosition.count == self.viewsToAnimate.count {
            UIView.animateWithDuration(1, delay: 0.0, options: .CurveEaseInOut,  animations: { () -> Void in
                for viewToAnimate in self.viewsToAnimate {
                    let currentFrame = viewToAnimate.frame
                    viewToAnimate.frame = CGRectMake(currentFrame.origin.x, self.viewsFinalYPosition.removeAtIndex(0), currentFrame.width, currentFrame.height)
                }
                }, completion: nil)
        }
    }
    
}
