//
//  SignViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANCommonKit
import Parse

enum SignType: Int {
    case Up = 0
    case In
}

class SignViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var signUpSwitchButton: UIButton!
    
    var signType: SignType!

    func initWithType(signType: SignType) {
        self.signType = signType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewFor(signType)
    }
    
    func configureViewFor(signType: SignType) {
        if signType == .Up {
            navigationBar.topItem?.title = "Sign up"
            signButton.setTitle("Sign up", forState: .Normal)
            forgotPasswordButton.hidden = true
            signUpSwitchButton.hidden = false
        } else {
            navigationBar.topItem?.title = "Sign in"
            signButton.setTitle("Sign in", forState: .Normal)
            forgotPasswordButton.hidden = false
            signUpSwitchButton.hidden = true
        }
    }
    
    func showRootTabBar() {
        view.endEditing(true)
        WorkflowController.presentRootTabBar(animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signPressed(sender: AnyObject) {
        
        emailTextField.trimSpaces()
        if !emailTextField.validEmail() {
            var alert = UIAlertController(title: "Invalid email", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        if signType == .Up {
            let user = PFUser()
            user.username = emailTextField.text
            user.password = passwordTextField.text
            user.email = emailTextField.text
            
            user.signUpInBackgroundWithBlock({ (succeeded, error) -> Void in
                
                if let error = error {
                    let errorMessage = error.userInfo?["error"] as! String
                    var alert = UIAlertController(title: "Woot", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    self.showRootTabBar()
                }
            })
        } else if signType == .In {
            
            PFUser.logInWithUsernameInBackground(emailTextField.text, password:passwordTextField.text) {
                (user: PFUser?, error: NSError?) -> Void in
                
                if let error = error {
                    // The login failed. Check error to see why.
                    let errorMessage = error.userInfo?["error"] as! String
                    var alert = UIAlertController(title: "Woot", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    self.showRootTabBar()
                }
            }
        }
        
    }
    
    @IBAction func switchToLoginPressed(sender: AnyObject) {
        signType = .In
        configureViewFor(signType)
    }
}

extension SignViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}