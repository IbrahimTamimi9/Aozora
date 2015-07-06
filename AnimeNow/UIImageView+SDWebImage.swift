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
    
    public func setImageFrom(#urlString:String!, animated:Bool = true)
    {
        if let url = NSURL(string: urlString) {
            if !animated {
                self.sd_setImageWithURL(url, placeholderImage: nil)
            } else {
                self.layer.removeAllAnimations()
                self.sd_cancelCurrentImageLoad()
                self.sd_setImageWithURL(url, placeholderImage: nil, completed: { (image, error, cacheType, url) -> Void in
                    self.alpha = 0
                    UIView.transitionWithView(self, duration: 0.5, options: nil, animations: { () -> Void in
                        self.image = image
                        self.alpha = 1
                        }, completion: nil)
                })
            }
        }
    }
}