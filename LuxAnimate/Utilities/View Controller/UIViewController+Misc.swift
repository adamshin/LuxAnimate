//
//  UIViewController+Misc.swift
//

import UIKit

extension UIViewController {
    
    func topViewController() -> UIViewController {
        if let presentedViewController,
            !presentedViewController.isBeingDismissed {
            
            return presentedViewController.topViewController()
            
        } else if let navigationController = self as? UINavigationController,
            let topViewController = navigationController.topViewController {
            
            return topViewController.topViewController()
            
        } else if let tabBarController = self as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            
            return selectedViewController.topViewController()
            
        } else {
            return self
        }
    }

}
