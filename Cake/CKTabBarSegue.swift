//
//  CKTabBarSegue.swift
//  Cake
//
//  Created by lola on 2/11/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit

class CKTabBarSegue: UIStoryboardSegue {
    
    override func perform() {
        let tabBarViewController = self.sourceViewController as! CKTabBarViewController
        let destinationViewController = tabBarViewController.destinationViewController
        
        // remove old view controller
        if tabBarViewController.oldViewController != nil {
            tabBarViewController.oldViewController.willMoveToParentViewController(nil)
            tabBarViewController.oldViewController.view.removeFromSuperview()
            tabBarViewController.oldViewController.removeFromParentViewController()
        }
        
        destinationViewController.view.frame = tabBarViewController.container.bounds
        tabBarViewController.addChildViewController(destinationViewController)
        tabBarViewController.container.addSubview(destinationViewController.view)
        destinationViewController.didMoveToParentViewController(tabBarViewController)
        
        //        tabBarViewController.updateViewConstraints()
        tabBarViewController.view.layoutIfNeeded()
        
    }
}
