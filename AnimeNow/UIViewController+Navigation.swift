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
import ANAnimeKit

extension UIViewController {
    
    func presentAnimeModal(anime: Anime) -> ZFModalTransitionAnimator {
        
        let tabBarController = ANAnimeKit.rootTabBarController()
        tabBarController.initWithAnime(anime)
        
        var animator = ZFModalTransitionAnimator(modalViewController: tabBarController)
        animator.dragable = true
        animator.direction = ZFModalTransitonDirection.Bottom
        
        tabBarController.animator = animator
        tabBarController.transitioningDelegate = animator;
        tabBarController.modalPresentationStyle = UIModalPresentationStyle.Custom;
        
        presentViewController(tabBarController, animated: true, completion: nil)
        
        return animator
    }
    
}