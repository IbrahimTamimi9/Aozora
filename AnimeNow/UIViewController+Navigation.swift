//
//  AnimePresenter.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/27/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANParseKit
import ANCommonKit
import JTSImageViewController

extension UIViewController {
    
    public func presentViewControllerModal(controller: UIViewController) -> ZFModalTransitionAnimator {
        
        var animator = ZFModalTransitionAnimator(modalViewController: controller)
        animator.dragable = true
        animator.direction = ZFModalTransitonDirection.Bottom

        controller.transitioningDelegate = animator;
        controller.modalPresentationStyle = UIModalPresentationStyle.Custom;
        
        presentViewController(controller, animated: true, completion: nil)
        
        return animator
    }
    
}