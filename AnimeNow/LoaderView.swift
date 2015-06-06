//
//  LoaderView.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/6/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit

class LoaderView: UIView {

    let rectShape = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        backgroundColor = UIColor.clearColor()
        
        rectShape.bounds = bounds
        rectShape.position = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
        rectShape.cornerRadius = bounds.width / 2
        rectShape.path = UIBezierPath(ovalInRect: rectShape.bounds).CGPath
        rectShape.fillColor = UIColor.midnightBlue().CGColor
    }
    
    func startAnimating() {

        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        let animationDuration = 0.4
        
        let sizingAnimation = CABasicAnimation(keyPath: "transform.scale")
        sizingAnimation.fromValue = 1
        sizingAnimation.toValue = 2
        sizingAnimation.timingFunction = timingFunction
        sizingAnimation.duration = animationDuration
        
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1
        fadeOut.toValue = 0
        fadeOut.timingFunction = timingFunction
        fadeOut.duration = animationDuration - 0.1
        fadeOut.removedOnCompletion = false
        fadeOut.fillMode = kCAFillModeForwards
        fadeOut.beginTime = 0.1
        
        let group = CAAnimationGroup()
        group.animations = [sizingAnimation, fadeOut]
        group.duration = animationDuration * 2.0
        group.repeatCount = HUGE
        
        layer.addSublayer(rectShape)
        rectShape.addAnimation(group, forKey: nil)

    }
    
    func stopAnimating() {
        rectShape.removeAllAnimations()
        rectShape.removeFromSuperlayer()
    }

}
