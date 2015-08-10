//
//  LoginViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/20/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import Bolts
import Alamofire
import ANParseKit
import Parse

public protocol LoginViewControllerDelegate: class {
    func loginViewControllerPressedDoesntHaveAnAccount()
}

public class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    
    public weak var delegate: LoginViewControllerDelegate?
    var loadingView: LoaderView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        loadingView = LoaderView(parentView: view)
    }
    
    // MARK: - Internal methods
    
    func verifyCredentials() -> BFTask! {
        let completionSource = BFTaskCompletionSource()
        
        loadingView.startAnimating()

        Alamofire.request(Atarashii.Router.verifyCredentials()).authenticate(user: usernameTextField.text, password: passwordTextField.text).validate().responseJSON { (req, res, JSON, error) -> Void in
            if error == nil {
                
                PFUser.malUsername = self.usernameTextField.text.stringByReplacingOccurrencesOfString(" ", withString: "")
                PFUser.malPassword = self.passwordTextField.text
                
                completionSource.setResult(JSON)
            } else {
                completionSource.setError(error)
            }
        }
        return completionSource.task
    }
    
    
    // MARK: - Actions
    @IBAction func dismissKeyboardPressed(sender: AnyObject) {
        
        view.endEditing(true)
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        verifyCredentials().continueWithBlock
        { (task: BFTask!) -> AnyObject! in
            
            self.loadingView.stopAnimating()
            
            if let error = task.error {
                println(error)
                UIAlertView(title: "Wrong credentials..", message: nil, delegate: nil, cancelButtonTitle: "Ok..").show()
            } else {
                UIAlertView(title: "Logged in!", message: nil, delegate: nil, cancelButtonTitle: "Ok").show()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            return nil
        }
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        delegate?.loginViewControllerPressedDoesntHaveAnAccount()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
