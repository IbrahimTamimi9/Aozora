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

        Alamofire.request(Atarashii.Router.verifyCredentials()).authenticate(user: usernameTextField.text!, password: passwordTextField.text!).validate().responseJSON { (req, res, result) -> Void in
            
            if result.isSuccess {
            
                User.currentUser()!.myAnimeListUsername = self.usernameTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
                User.currentUser()!.myAnimeListPassword = self.passwordTextField.text
                
                completionSource.setResult(result.value)
            } else {
                completionSource.setError(nil)
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
                print(error)
                UIAlertView(title: "Wrong credentials..", message: nil, delegate: nil, cancelButtonTitle: "Ok..").show()
            } else {
                UIAlertView(title: "Linked with MyAnimelist!", message: nil, delegate: nil, cancelButtonTitle: "Ok").show()
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
