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
    }
    
    
    // MARK: - IBActions
    
    @IBAction func selectedFavoriteAnimeButton(sender: AnyObject) {
        
    }
    
    @IBAction func seeMorePressed(sender: AnyObject) {
        
    }
    
    
}