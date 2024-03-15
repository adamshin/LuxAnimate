//
//  UIScrollView+Misc.swift
//

import UIKit

extension UIScrollView {
    
    var topOffset: CGFloat {
        -adjustedContentInset.top
    }
    
    var bottomOffset: CGFloat {
        contentSize.height + adjustedContentInset.bottom - bounds.height
    }
    
    var distanceToTop: CGFloat { contentOffset.y - topOffset }
    var distanceToBottom: CGFloat { bottomOffset - contentOffset.y }
    
    var isAtTop: Bool { distanceToTop < 0.1 }
    var isAtBottom: Bool { distanceToBottom < 0.1 }
    
    var isScrollable: Bool {
        let scrollableHeight = contentSize.height
            + adjustedContentInset.top
            + adjustedContentInset.bottom
        return scrollableHeight > bounds.height
    }
    
    func scrollToTop(animated: Bool) {
        setContentOffset(
            CGPoint(x: 0, y: topOffset),
            animated: animated)
    }
    
    func scrollToBottom(animated: Bool) {
        setContentOffset(
            CGPoint(x: 0, y: bottomOffset),
            animated: animated)
    }
    
}
