//
//  CustomTabBar.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/9/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANParseKit
import ANCommonKit
import ANAnimeKit

public class RootTabBar: UITabBarController {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
}

extension RootTabBar: UITabBarControllerDelegate {
    public func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        if let navController = viewController as? UINavigationController,
            let controller = navController.viewControllers.first as? ProfileViewController  {
            
            if PFUser.currentUserLoggedIn() {
                // Logged in both
                controller.initWithUsername(PFUser.malUsername!)
                return true
                
            } else if PFUser.currentUserIsGuest() {
                
                let onboarding = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController() as! OnboardingViewController
                onboarding.isInWindowRoot = false
                presentViewController(onboarding, animated: true, completion: nil)
                
                return false
                
            } else {
                
                // Only logged with email/fb
                let storyboard = UIStoryboard(name: "Login", bundle: ANAnimeKit.bundle())
                let loginController = storyboard.instantiateInitialViewController() as! LoginViewController
                presentViewController(loginController, animated: true, completion: nil)
                return false
                
            }
        }
        
        return true
    }
}