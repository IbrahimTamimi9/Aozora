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

public protocol ModalTransitionScrollable {
    var transitionScrollView: UIScrollView? { get }
}

public protocol ModalTransitionAnimatable: ModalTransitionScrollable {
    var animator: ZFModalTransitionAnimator! { get set }
}

extension ModalTransitionAnimatable {
    public func updateTransitionScrollView() {
        if let transitionScrollView = transitionScrollView {
            animator.gesture.enabled = true
            animator.setContentScrollView(transitionScrollView)
        }
    }
}

extension UIViewController {
    
    public func presentViewControllerModal(controller: UIViewController) -> ZFModalTransitionAnimator {
        
        let animator = ZFModalTransitionAnimator(modalViewController: controller)
        animator.dragable = true
        animator.direction = .Bottom

        controller.transitioningDelegate = animator
        controller.modalPresentationStyle = .Custom
        
        presentViewController(controller, animated: true) { _ in
            if var controller = controller as? ModalTransitionAnimatable {
                controller.animator = animator
                controller.updateTransitionScrollView()
            }
        }
        
        return animator
    }
    
}