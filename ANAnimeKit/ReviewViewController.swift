//
//  ReviewViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/12/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit

public class ReviewViewController: UIViewController {
    
    var animeReview: AnimeReview.Review!
    
    @IBOutlet weak var personAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var helpfulLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var reviewLabel: UITextView!
    
    func initWithReview(review: AnimeReview.Review) {
        self.animeReview = review
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Review"
        
        scrapeReviewWith(id: 22681)
        
        personAvatar.setImageFrom(urlString: animeReview.avatarUrl)
        usernameLabel.text = animeReview.username
        helpfulLabel.text = animeReview.helpfulString()
        ratingLabel.text = animeReview.rating.description
        
        
    }
    
    func scrapeReviewWith(#id: Int) {
        let requestURL = "http://myanimelist.net/reviews.php?id=\(id)"
        
        self.webScraper.scrape(requestURL) { (hpple) -> Void in
            if hpple == nil {
                println("hpple is nil")
                return
            }
            
            let review = hpple.searchWithXPathQuery("//span[@class='fs16 lh20 t22681-text']") as! [TFHppleElement]
            
            for info in review {
                let reviewString = info.childrenContentByRemovingHtml()
                self.reviewLabel.text = reviewString
                self.reviewLabel.font = UIFont.systemFontOfSize(15)
            }
        }
        
    }
    
}

