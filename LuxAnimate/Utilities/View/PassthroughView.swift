//
//  PassthroughView.swift
//

import UIKit

class PassthroughView: UIView {
    
    override func hitTest(
        _ point: CGPoint, with event: UIEvent?
    ) -> UIView? {
        passthroughHitTest(point, with: event)
    }
    
}

class PassthroughStackView: UIStackView {
    
    override func hitTest(
        _ point: CGPoint, with event: UIEvent?
    ) -> UIView? {
        passthroughHitTest(point, with: event)
    }
    
}

extension UIView {
    
    fileprivate func passthroughHitTest(
        _ point: CGPoint, with event: UIEvent?
    ) -> UIView? {
        guard isUserInteractionEnabled else { return nil }
        guard !isHidden else { return nil }
        guard alpha >= 0.01 else { return nil }
        
        for subview in subviews.reversed() {
            let p = subview.convert(point, from: self)
                
            if let view = subview.hitTest(p, with: event) {
                return view
            }
        }
        return nil
    }
    
}
