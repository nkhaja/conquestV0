//
//  AppDelegate.swift
//  conquestV0
//
//  Created by Nabil K on 2016-07-11.
//  Copyright © 2016 Nabil. All rights reserved.
//

import UIKit

import MapKit
import FBSDKCoreKit
import Parse
import ParseUI
import ParseFacebookUtilsV4


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var parseLoginHelper: ParseLoginHelper!
    var window: UIWindow?
    
    override init() {
        super.init()
        
        parseLoginHelper = ParseLoginHelper {[unowned self] user, error in
            // Initialize the ParseLoginHelper with a callback
            if let error = error {
                // 1
                ErrorHandling.defaultErrorHandler(error)
            } else  if let _ = user {
                // if login was successful, display the TabBarController
                // 2
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let startController = storyboard.instantiateViewControllerWithIdentifier("first")
                // 3
                self.window?.rootViewController!.presentViewController(startController, animated:true, completion:nil)
            }
        }
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Set up the Parse SDK
        let configuration = ParseClientConfiguration {
            $0.applicationId = "conquest"
            $0.server = "https://conquest-nkhaja.herokuapp.com/parse"
        }
        Parse.initializeWithConfiguration(configuration)
        
        let acl = PFACL()
        acl.publicReadAccess = true
        PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
        
        // Initialize Facebook
        // 1
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // check if we have logged in user
        // 2
        let user = PFUser.currentUser()
        //PFUser.logOut()

        
        let startViewController: UIViewController;
        
//        if (user != nil) {
//            // 3
//            // if we have a user, set the TabBarController to be the initial view controller
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            startViewController = LogInViewController() //storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
//        } else {
//            // 4
//            // Otherwise set the LoginViewController to be the first
            let loginViewController = LogInViewController()
            loginViewController.fields = [.UsernameAndPassword, .LogInButton, .SignUpButton, .Facebook] //  .PasswordForgotten,
            loginViewController.delegate = parseLoginHelper
            loginViewController.signUpController = SignUpViewController() // MARK: Tried SignUp Here!
            loginViewController.signUpController?.delegate = parseLoginHelper

            startViewController = loginViewController
//        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = startViewController;
        self.window?.makeKeyAndVisible()
        
        // make white the default color for selected tab bar entries
        //UITabBar.appearance().tintColor = MapHelper.hexStringToUIColor("#bbeaf4")
        
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }



    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: Facebook Integration
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }


}

