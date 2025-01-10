//
//  ContainerViewController.swift
//

import UIKit

class ContainerViewController: UIViewController {
    
    private(set) var currentViewController: UIViewController?
    
    // MARK: - Lifecycle
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        currentViewController?.supportedInterfaceOrientations
            ?? .portrait
    }
    
    override var childForStatusBarStyle: UIViewController? {
        currentViewController
    }
    override var childForStatusBarHidden: UIViewController? {
        currentViewController
    }
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        currentViewController
    }
    override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        currentViewController
    }
    
    // MARK: - View Controllers
    
    func show(_ vc: UIViewController?) {
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()
        
        if let vc {
            addChild(vc)
            view.addSubview(vc.view)
            vc.didMove(toParent: self)
            
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                vc.view.topAnchor.constraint(equalTo: view.topAnchor),
                vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
            
            currentViewController = vc
        }
        
        setNeedsStatusBarAppearanceUpdate()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
    }
    
}

class PassthroughContainerViewController:
    ContainerViewController {
    
    override func loadView() {
        view = PassthroughView()
    }
    
}
