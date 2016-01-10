//
//  AboutViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 1/9/16.
//  Copyright © 2016 AnyTap. All rights reserved.
//

import Foundation
import ANParseKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var aboutLabel: UILabel!
    
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var animeProgressWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var watchedAnimeTimeLabel: UILabel!
    
    @IBOutlet var favoriteAnimeButtons: [UIButton]!
    
    
    var user: User!
    
    func initWithUser(user: User) {
        self.user = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        
        let userDetails = user.details
        
        aboutLabel.text = userDetails.about
        let gender = Gender(rawValue: userDetails.gender) ?? .Select
        
        if gender == .Male {
            genderImageView.image = UIImage(named: "icon-male")
        } else if gender == .Female {
            genderImageView.image = UIImage(named: "icon-female")
        } else {
            genderImageView.image = nil
        }
        
        if let birthday = userDetails.birthday {
            
            let calendar = NSCalendar.currentCalendar()
            let flags = NSCalendarUnit.Year
            let components = calendar.components(flags, fromDate: birthday, toDate: NSDate(), options: [])
            
            ageLabel.text = "\(components.year)"
        } else {
            ageLabel.text = "Unknown age"
        }
        
        if let geopoint = userDetails.location {
            let location = CLLocation(latitude: geopoint.latitude, longitude: geopoint.longitude)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                print(location)
                
                if let error = error {
                    print("Reverse geocoder failed with error" + error.localizedDescription)
                    return
                } else if let placemarks = placemarks {
                    if placemarks.count > 0 {
                        let placemark = placemarks[0]
                        if let city = placemark.locality, let state = placemark.administrativeArea, let country = placemark.country {
                            
                            if country == "United States" {
                                self.locationLabel.text = "\(city), \(state)"
                            } else {
                                self.locationLabel.text = "\(city), \(country)"
                            }
                        }
                    } else {
                        self.locationLabel.text = "Unknown"
                        print("Problem with the data received from geocoder")
                    }
                }
            })
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func selectedFavoriteAnimeButton(sender: AnyObject) {
        
    }
    
    @IBAction func seeMorePressed(sender: AnyObject) {
        
    }
}