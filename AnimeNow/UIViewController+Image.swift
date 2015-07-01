//
//  AnimePresenter.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/27/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import JTSImageViewController

extension UIViewController {
    
    public func presentImageViewController(imageView: UIImageView, imageUrl: NSURL? = nil) {
        
        let imageInfo = JTSImageInfo()
        if let image = imageView.image {
            imageInfo.image = image
        } else {
            imageInfo.imageURL = imageUrl
        }
        imageInfo.referenceRect = imageView.frame
        imageInfo.referenceView = imageView
        
        let controller = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Blurred)
        controller.showFromViewController(self, transition: JTSImageViewControllerTransition._FromOriginalPosition)
    }
    
}