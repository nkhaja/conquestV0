//
//  SignUpViewController.swift
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
class SignUpViewController : PFSignUpViewController {
    
    var backgroundImage : UIImageView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set our custom background image
        backgroundImage = UIImageView(image: UIImage(named: "login"))
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        signUpView!.insertSubview(backgroundImage, atIndex: 0)
        
        // remove the parse Logo
        let logo = UILabel()
        logo.text = ""
        logo.textColor = UIColor.whiteColor()
        logo.font = UIFont(name: "Avenir Next", size: 70)
        logo.shadowColor = UIColor.lightGrayColor()
        //logo.shadowOffset = CGSizeMake(2, 2)
        signUpView?.logo = logo
        
        // make the background of the sign up button pop more
        signUpView?.signUpButton!.setBackgroundImage(nil, forState: .Normal)
        signUpView?.signUpButton!.backgroundColor = UIColor.blackColor()  //MapHelper.hexStringToUIColor("36B0FF")
        
        // change dismiss button to say 'Already signed up?'
        signUpView?.dismissButton!.setTitle("Already signed up?", forState: .Normal)
        signUpView?.dismissButton!.setImage(nil, forState: .Normal)
        signUpView?.dismissButton!.backgroundColor = MapHelper.hexStringToUIColor("36B0FF")
        
        // modify the present tranisition to be a flip instead
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        backgroundImage.frame = CGRectMake( 0,  0,  signUpView!.frame.width,  signUpView!.frame.height)
        
        // position logo at top with larger frame
        signUpView!.logo!.sizeToFit()
        let logoFrame = signUpView!.logo!.frame
        signUpView!.logo!.frame = CGRectMake(logoFrame.origin.x, signUpView!.usernameField!.frame.origin.y - logoFrame.height - 16, signUpView!.frame.width,  logoFrame.height)
        
        // re-layout out dismiss button to be below sign
        let dismissButtonFrame = signUpView!.dismissButton!.frame
        signUpView?.dismissButton!.frame = CGRectMake(0, signUpView!.signUpButton!.frame.origin.y + signUpView!.signUpButton!.frame.height + 16.0,  signUpView!.frame.width,  dismissButtonFrame.height)
    }
    
}
