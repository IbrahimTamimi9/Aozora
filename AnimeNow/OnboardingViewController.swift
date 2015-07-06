//
//  OnboardingViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var facebookLoginButton: UIButton!
    
    var isInWindowRoot = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSign" {
            
            if let senderType = sender as? Int, let type = SignType(rawValue: senderType) {
                let sign = segue.destinationViewController as! SignViewController
                sign.isInWindowRoot = isInWindowRoot
                sign.initWithType(type)
            }
            
        }
    }
    
    func presentRootTabBar() {
        
        OnboardingViewController.initializeUserDataIfNeeded()
        
        if isInWindowRoot {
            WorkflowController.presentRootTabBar(animated: true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    class func initializeUserDataIfNeeded() {
        if let currentUser = PFUser.currentUser() where currentUser["joinDate"] == nil {
            currentUser["joinDate"] = NSDate()
            currentUser.saveEventually()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func signUpWithFacebookPressed(sender: AnyObject) {
        let permissions = ["public_profile", "email", "user_friends"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    println("User signed up and logged in through Facebook!")
                } else {
                    println("User logged in through Facebook!")
                }
                self.presentRootTabBar()
            } else {
                println("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    @IBAction func signUpWithEmailPressed(sender: AnyObject) {

        performSegueWithIdentifier("showSign", sender: SignType.Up.rawValue)
    }
    
    @IBAction func skipSignUpPressed(sender: AnyObject) {
        
        if PFUser.currentUserIsGuest() {
            presentRootTabBar()
        } else {
            PFAnonymousUtils.logInWithBlock {
                (user: PFUser?, error: NSError?) -> Void in
                if error != nil || user == nil {
                    println("Anonymous login failed.")
                    var alert = UIAlertController(title: "Woot", message: "Anonymous login failed", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    println("Anonymous user logged in.")
                    self.presentRootTabBar()
                }
            }
        }
        
    }
    
    @IBAction func signInPressed(sender: AnyObject) {
        
        performSegueWithIdentifier("showSign", sender: SignType.In.rawValue)
    }
}
