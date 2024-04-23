//
//  UIViewController+Extensions.swift
//

import UIKit

extension UIViewController {
    
    func addChild(
        _ childVC: UIViewController,
        to containerView: UIView
    ) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.didMove(toParent: self)
        
        childVC.view.pinEdges(to: containerView)
    }
    
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
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(
            title: title, message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
            title: "OK", style: .cancel,
            handler: { _ in }))
        
        present(alert, animated: true)
    }
    
}
