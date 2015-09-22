//
//  ImageViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/6/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation

protocol ImageViewControllerDelegate: class {
    func imageViewControllerSelected(imageData imageData: ImageData)
}

public class ImageViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: ImageViewControllerDelegate?
    var imageData: ImageData!
    
    func initWith(imageData imageData: ImageData) {
        self.imageData = imageData
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        imageView.setImageFrom(urlString: imageData.url, animated: true)
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    // MARK: - IBActions
    
    @IBAction func backPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func selectPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            delegate?.imageViewControllerSelected(imageData: imageData)
        })
    }
}

extension ImageViewController: UIScrollViewDelegate {
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        
    }
}