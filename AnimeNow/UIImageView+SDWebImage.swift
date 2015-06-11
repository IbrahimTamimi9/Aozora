//
//  UIImageView+SDWebImage.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/10/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {
    public func setImageWithAnimationFrom(#urlString:String!)
    {
        image = nil
        if let url = NSURL(string: urlString) {
            SDWebImageManager.sharedManager().downloadImageWithURL(url, options: nil, progress: nil) { (downloadedImage:UIImage!, error:NSError!, cacheType:SDImageCacheType, isDownloaded:Bool, withURL:NSURL!) -> Void in
                self.alpha = 0
                UIView.transitionWithView(self, duration: 0.5, options: nil, animations: { () -> Void in
                    self.image = downloadedImage
                    self.alpha = 1
                    }, completion: nil)
                
            }
        }
    }
}