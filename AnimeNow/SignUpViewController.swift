//
//  SignViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/29/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANCommonKit
import RSKImageCropper
import ANParseKit

class SignUpViewController: UIViewController {
    
    let ImageMinimumSideSize: CGFloat = 120
    let ImageMaximumSideSize: CGFloat = 400
    
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    var loggedInWithFacebook = false
    var isInWindowRoot = true
    var imagePicker: UIImagePickerController!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if loggedInWithFacebook {
            passwordTextField.hidden = true
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
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
    
    @IBAction func selectProfilePicturePressed(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            if imagePicker == nil {
                imagePicker = UIImagePickerController()
            }
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func dismissPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        emailTextField.trimSpaces()
        if !emailTextField.validEmail() {
            var alert = UIAlertController(title: "Invalid email", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if count(usernameTextField.text) < 3 {
            var alert = UIAlertController(title: "Invalid username", message: "Make it 3 characters or longer", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if usernameTextField.text.rangeOfString(" ") != nil {
            var alert = UIAlertController(title: "Invalid username", message: "It can't have spaces", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        usernameTextField.trimSpaces()
        let username = usernameTextField.text
        usernameIsUnique(username).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
            
            if let user = task.result as? PFUser {
                return BFTask(error: NSError(domain: "Aozora.App", code: 700, userInfo: ["error": "User exists, try another one"]))
            }
            
            let user = PFUser()
            
            // Fill user fields
            if user.username == nil {
                user.username = username
            }
            
            user["aozoraUsername"] = username
            user.password = self.passwordTextField.text
            user.email = self.emailTextField.text
            
            let avatar = self.profilePicture.image ?? UIImage(named: "default-avatar")!
            
            let thumbAvatar = UIImage.imageWithImage(avatar, newSize: CGSize(width: self.ImageMinimumSideSize, height: self.ImageMinimumSideSize))
            let avatarThumbData = UIImagePNGRepresentation(thumbAvatar)
            let avatarThumbFile = PFFile(name:"avatarThumb.png", data:avatarThumbData)
            user["avatarThumb"] = avatarThumbFile
            
            // Add user detail object
            let regularAvatar = UIImage.imageWithImage(avatar, maxSize: CGSize(width: self.ImageMaximumSideSize, height: self.ImageMaximumSideSize))
            let avatarRegularData = UIImagePNGRepresentation(regularAvatar)
            let avatarRegularFile = PFFile(name:"avatarRegular.png", data:avatarRegularData)
            
            let userDetails = UserDetails()
            userDetails.avatarRegular = avatarRegularFile
            userDetails.about = ""
            userDetails.planningAnimeCount = 0
            userDetails.watchingAnimeCount = 0
            userDetails.completedAnimeCount = 0
            userDetails.onHoldAnimeCount = 0
            userDetails.droppedAnimeCount = 0
            userDetails.gender = "Not specified"
            userDetails.joinDate = NSDate()
            userDetails.posts = 0
            userDetails.watchedTime = 0.0
            user["userDetails"] = userDetails
            
            return user.signUpInBackground()
        }).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject! in
            
            if let error = task.error {
                let errorMessage = error.userInfo?["error"] as! String
                var alert = UIAlertController(title: "Username in use", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                self.showRootTabBar()
            }
            return nil
        })
    
    }
    
    // MARK: - Parse calls
    
    func usernameIsUnique(username: String) -> BFTask {

        let query = PFUser.query()!
        query.limit = 1
        query.whereKey("aozoraUsername", equalTo: username)
        return query.findObjectsInBackground()
    }
    
}

extension SignUpViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SignUpViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        if textField == passwordTextField {
            loginPressed(textField)
        }
        return true
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            if image.size.width < self.ImageMinimumSideSize || image.size.height < self.ImageMinimumSideSize {
                var alert = UIAlertController(title: "Pick a larger image", message: "Select an image with at least 120x120px", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let imageCropVC = RSKImageCropViewController(image: image)
                imageCropVC.delegate = self
                self.presentViewController(imageCropVC, animated: true, completion: nil)
            }
        })
    }
}

extension SignUpViewController: RSKImageCropViewControllerDelegate {
    func imageCropViewController(controller: RSKImageCropViewController!, didCropImage croppedImage: UIImage!, usingCropRect cropRect: CGRect) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        selectImageButton.setTitle("", forState: .Normal)
        profilePicture.image = croppedImage
    }
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}