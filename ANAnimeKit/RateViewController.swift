//
//  RateViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/24/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import HCSStarRatingView
import RealmSwift
import ANParseKit

public protocol RateViewControllerProtocol: class {
    func rateControllerDidFinishedWith(#anime: Anime, rating: Float)
}

public class RateViewController: UIViewController {
    
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var starRating: HCSStarRatingView!
    
    weak var delegate: RateViewControllerProtocol?
    
    var currentRating: Float = 0
    var message: String = ""
    var anime: Anime!
    
    public class func showRateDialogWith(viewController: UIViewController, title: String, initialRating: Float, anime: Anime, delegate: RateViewControllerProtocol) {
        
        let controller = UIStoryboard(name: "Rate", bundle: ANAnimeKit.bundle()).instantiateInitialViewController() as! RateViewController
        
        controller.initWith(anime, title: title, initialRating: initialRating, delegate: delegate)
        
        controller.modalTransitionStyle = .CrossDissolve
        controller.modalPresentationStyle = .OverCurrentContext
        viewController.presentViewController(controller, animated: true, completion: nil)
    }
    
    public class func updateAnime(anime: Anime, withRating rating: Float) {
        let realm = Realm()
        
        if let progress = anime.progress {
            realm.write({ () -> Void in
                progress.score = Int(rating)
            })
            
            LibrarySyncController.updateAnime(progress)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(ANAnimeKit.LibraryUpdatedNotification, object: nil)
    }
    
    func initWith(anime: Anime, title: String, initialRating: Float, delegate: RateViewControllerProtocol) {
        
        message = title
        currentRating = initialRating
        self.anime = anime
        self.delegate = delegate
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = message
        starRating.value = CGFloat(currentRating)
    }
    
    // MARK: - IBActions
    
    @IBAction func ratingChanged(sender: HCSStarRatingView) {
        delegate?.rateControllerDidFinishedWith(anime: anime, rating: Float(sender.value))
    }
    
    @IBAction func dismissViewController(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}