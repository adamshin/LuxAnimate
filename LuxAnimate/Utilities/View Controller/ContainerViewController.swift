//
//  ContainerViewController.swift
//

import UIKit

class ContainerViewController: UIViewController {
    
    private(set) var currentViewController: UIViewController?
    
    // MARK: - Lifecycle
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return currentViewController?.supportedInterfaceOrientations
            ?? .portrait
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return currentViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return currentViewController
    }
    
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return currentViewController
    }
    
    override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return currentViewController
    }
    
    // MARK: - View Controllers
    
    func show(_ viewController: UIViewController?) {
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()
        
        if let viewController {
            add(viewController, to: view)
            currentViewController = viewController
        }
        
        setNeedsStatusBarAppearanceUpdate()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
    }
    
}
