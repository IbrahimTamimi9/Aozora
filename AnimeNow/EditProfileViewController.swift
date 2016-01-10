//
//  EditProfileViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Bolts
import ANParseKit

protocol EditProfileViewControllerProtocol: class {
    func editProfileViewControllerDidEditedUser(user: User)
}

public enum Gender: String {
    case Male = "Male"
    case Female = "Female"
    case Select = "Select"
}


public class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    
    @IBOutlet weak var saveBBI: UIBarButtonItem!
    
    @IBOutlet weak var formWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var birthdayButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var datePickerView: UIView!
    
    weak var delegate: EditProfileViewControllerProtocol?
    var user = User.currentUser()!
    var userProfileManager = UserProfileManager()
    var updatedAvatar = false
    var updatedBanner = false
    
    var location: CLLocation? {
        didSet {
            if let location = location {
                geocodeLocation(location)
            }
        }
    }
    var timezoneName: String?
    var birthday: NSDate? {
        didSet {
            if let birthday = birthday {
                birthdayButton.setTitle(birthday.mediumDate(), forState: .Normal)
            }
        }
    }
    
    var gender: Gender? {
        didSet {
            if let gender = gender {
                genderButton.setTitle(gender.rawValue, forState: .Normal)
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.textColor = UIColor.blackColor()
        
        userProfileManager.initWith(self, delegate: self)
        
        if let avatarFile = user.avatarThumb {
            avatarImageView.setImageWithPFFile(avatarFile, animated: true)
        }
        
        if let bannerFile = user.banner {
            bannerImageView.setImageWithPFFile(bannerFile, animated: true)
        }
        
        emailTextField.text = user.email
        user.details.fetchIfNeededInBackgroundWithBlock({ (details, error) -> Void  in
            if let details = details as? UserDetails {
                self.formWidthConstraint.constant = self.view.bounds.size.width
                self.avatarViewWidthConstraint.constant = self.formWidthConstraint.constant / 2 - 8
                self.aboutTextView.text = details.about
                
                self.location = CLLocation(latitude: details.location.latitude, longitude: details.location.longitude)
                self.timezoneName = details.timezone
                self.birthday = details.birthday
                self.gender = Gender(rawValue: details.gender) ?? Gender.Select
                
                self.view.layoutIfNeeded()
            }
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - NSNotificationCenter
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo! as NSDictionary
        
        let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardEndFrame = view.convertRect(endFrameValue.CGRectValue(), fromView: nil)
        
        updateInputForHeight(keyboardEndFrame.size.height)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        updateInputForHeight(0)
    }
    
    // MARK: - Functions
    
    func updateInputForHeight(height: CGFloat) {
        
        scrollViewBottomSpaceConstraint.constant = height
        
        view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    // MARK: - IBAction
    
    @IBAction func changeAvatar(sender: AnyObject) {
        userProfileManager.selectAvatar()
    }
    
    @IBAction func changeBanner(sender: AnyObject) {
        userProfileManager.selectBanner()
    }
    
    @IBAction func dismissController(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveUser(sender: AnyObject) {
        
        if datePickerView.hidden == false {
            datePickerView.hidden = true
            saveBBI.title = "Save"
            updateBirthday(datePicker.date)
            return
        }
        
        saveBBI.enabled = false
        let updateTask = userProfileManager.updateUser(
            self,
            user: user,
            email: emailTextField.text,
            avatar: updatedAvatar ? avatarImageView.image : nil,
            banner: updatedBanner ? bannerImageView.image : nil,
            about: aboutTextView.text,
            location: location,
            gender: gender,
            birthday: birthday,
            timezone: timezoneName)
            
        updateTask.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                self.delegate?.editProfileViewControllerDidEditedUser(self.user)
                self.dismissViewControllerAnimated(true, completion: nil)
                return nil
            }.continueWithBlock { (task: BFTask!) -> AnyObject! in
                self.saveBBI.enabled = true
                return nil
        }
    }
    
    lazy var locationManager = CLLocationManager()
    
    @IBAction func getCurrentLocation(sender: AnyObject) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func selectGender(sender: AnyObject) {
        let alert = UIAlertController(title: "Select your gender", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.popoverPresentationController?.sourceView = sender.superview
        alert.popoverPresentationController?.sourceRect = sender.frame
        
        alert.addAction(UIAlertAction(title: "Male", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction) -> Void in
            self.updateGender(.Male)
        }))
        
        alert.addAction(UIAlertAction(title: "Female", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction) -> Void in
            self.updateGender(.Female)
        }))
        
        alert.addAction(UIAlertAction(title: "Do not specify", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction) -> Void in
            self.updateGender(.Select)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func selectBirthday(sender: AnyObject) {
        datePickerView.hidden = false
        datePicker.maximumDate = NSDate()
        saveBBI.title = "Select"
    }
    
    
    func updateLocation(placemark: CLPlacemark) {
        if let city = placemark.locality, let state = placemark.administrativeArea, let country = placemark.country {
            
            if country == "United States" {
                locationButton.setTitle("\(city), \(state)", forState: .Normal)
            } else {
                locationButton.setTitle("\(city), \(country)", forState: .Normal)
            }
        }
        
        if #available(iOS 9.0, *) {
            if let timezone = placemark.timeZone {
                timezoneName = timezone.name
            }
        }
    }
    
    func updateGender(gender: Gender) {
        self.gender = gender
    }
    
    func updateBirthday(date: NSDate) {
        birthday = date
    }

}

extension EditProfileViewController: UINavigationBarDelegate {
    public func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}

extension EditProfileViewController: UserProfileManagerDelegate {
    public func selectedAvatar(avatar: UIImage) {
        updatedAvatar = true
        avatarImageView.image = avatar
    }
    
    public func selectedBanner(banner: UIImage) {
        updatedBanner = true
        bannerImageView.image = banner
    }
}

extension EditProfileViewController: UITextViewDelegate {
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        view.layoutIfNeeded()
        return true
    }
}

extension EditProfileViewController: CLLocationManagerDelegate {
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        self.location = location
        manager.stopUpdatingLocation()
    }
    
    func geocodeLocation(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            
            if let error = error {
                print("Reverse geocoder failed with error" + error.localizedDescription)
                return
            } else if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placemark = placemarks[0]
                    self.updateLocation(placemark)
                } else {
                    print("Problem with the data received from geocoder")
                }
            }
        })
    }
}