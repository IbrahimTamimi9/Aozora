//
//  AnimePresenter.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/27/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANCommonKit
import JTSImageViewController

extension UIViewController {
    
    public func presentViewControllerModal(controller: UIViewController) -> ZFModalTransitionAnimator {
        
        let animator = ZFModalTransitionAnimator(modalViewController: controller)
        animator.dragable = true
        animator.direction = .Bottom

        controller.transitioningDelegate = animator
        controller.modalPresentationStyle = .Custom
        
        presentViewController(controller, animated: true, completion: nil)
        
        return animator
    }
    
}