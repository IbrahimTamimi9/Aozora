//
//  ANCommonKit.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/9/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

public class ANCommonKit {
    
    public class func bundle() -> NSBundle {
        return NSBundle(forClass: self)
    }
    
    public class func defaultStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Action", bundle: bundle())
    }
    
    public class func actionListViewController() -> ActionListViewController {
        let controller = defaultStoryboard().instantiateViewControllerWithIdentifier("ActionList") as! ActionListViewController
        return controller
    }
    
    public class func dropDownListViewController() -> DropDownListViewController {
        let controller = defaultStoryboard().instantiateViewControllerWithIdentifier("DropDownList") as! DropDownListViewController
        return controller
    }
    
    public class func webViewController() -> (UINavigationController,InAppBrowserViewController) {
        let controller = UIStoryboard(name: "InAppBrowser", bundle: NSBundle(forClass: self)).instantiateInitialViewController() as! UINavigationController
        return (controller,controller.viewControllers.last! as! InAppBrowserViewController)
    }
}

public enum FontAwesome: String {
    case AngleDown = ""
    case TimesCircle = ""
    case Ranking = ""
    case Members = ""
    case Watched = ""
}