//
//  UIViewController+Child.swift
//

import UIKit

extension UIViewController {
    
    func add(_ childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.didMove(toParent: self)
        
        childVC.view.pinEdges(to: containerView)
    }
    
}
