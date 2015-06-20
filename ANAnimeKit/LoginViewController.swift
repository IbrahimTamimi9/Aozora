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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    
    var loadingView: LoaderView!
    var malScrapper: MALScrapper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView = LoaderView(viewController: self)
        malScrapper = MALScrapper(viewController: self)
    }
    
    // MARK: - Internal methods
    
    func verifyCredentials() -> BFTask! {
        let completionSource = BFTaskCompletionSource()
        
        loadingView.startAnimating()

        Alamofire.request(Atarashii.Router.verifyCredentials()).authenticate(user: usernameTextField.text, password: passwordTextField.text).validate().responseJSON { (req, res, JSON, error) -> Void in
            if error == nil {
                
                User.username = self.usernameTextField.text
                User.password = self.passwordTextField.text
                
                completionSource.setResult(JSON)
            } else {
                completionSource.setError(error)
            }
        }
        return completionSource.task
    }
    
    
    // MARK: - Actions
    
    @IBAction func loginPressed(sender: AnyObject) {
        verifyCredentials().continueWithSuccessBlock
        { (task: BFTask!) -> AnyObject! in
            return self.malScrapper.loginWith(username: User.username!, password: User.password!)
            
        }.continueWithBlock
        { (task: BFTask!) -> AnyObject! in
            
            self.loadingView.stopAnimating()
            
            if let error = task.error {
                UIAlertView(title: "Wrong credentials..", message: nil, delegate: nil, cancelButtonTitle: "What?! Ok..").show()
            } else {
                UIAlertView(title: "Logged in!", message: nil, delegate: nil, cancelButtonTitle: "Cool").show()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            return nil
        }
    }
    
    @IBAction func signupPressed(sender: AnyObject) {
        let (navController, controller) = ANCommonKit.webViewController()
        
        controller.title = "Start using MyAnimeList"
        controller.initialUrl = NSURL(string: "http://myanimelist.net/login.php")
        presentViewController(navController, animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
