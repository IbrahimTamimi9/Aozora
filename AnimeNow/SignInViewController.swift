//
//  SignInViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/27/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

//
//  SignViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANCommonKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var isInWindowRoot = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showRootTabBar() {
        view.endEditing(true)
        OnboardingViewController.initializeUserDataIfNeeded()
        
        if isInWindowRoot {
            WorkflowController.presentRootTabBar(animated: true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signInPressed(sender: AnyObject) {
        
        usernameTextField.trimSpaces()
        
        PFUser.logInWithUsernameInBackground(usernameTextField.text, password:passwordTextField.text) {
            (user: PFUser?, error: NSError?) -> Void in
            
            if let error = error {
                // The login failed. Check error to see why.
                let errorMessage = error.userInfo?["error"] as! String
                var alert = UIAlertController(title: "Hmm", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.showRootTabBar()
            }
        }
    }
    
}

extension SignInViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        if textField == passwordTextField {
            signInPressed(textField)
        }
        return true
    }
}
