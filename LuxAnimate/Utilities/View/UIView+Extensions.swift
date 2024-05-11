//
//  UIView+Extensions.swift
//

import UIKit

// MARK: - UIView

extension UIView {

    func subviewsRecursive() -> [UIView] {
        subviews + subviews.flatMap { $0.subviewsRecursive() }
    }

}

// MARK: - UIScrollView

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

// MARK: - UITableView

extension UITableView {
    
    func reconfigureVisibleCells() {
        UIView.performWithoutAnimation {
            reconfigureRows(at: indexPathsForVisibleRows ?? [])
        }
    }
    
}

extension UITableView {
    
    func register<C: UITableViewCell>(_ cellType: C.Type) {
        register(cellType, forCellReuseIdentifier: C.name)
    }
    
    func dequeue<C: UITableViewCell>(
        _ cellClass: C.Type,
        for indexPath: IndexPath
    ) -> C {
        dequeueReusableCell(
            withIdentifier: cellClass.name,
            for: indexPath) as! C
    }
    
    func dequeue<C: UITableViewCell>(
        _ cellType: C.Type,
        configure: (C) -> Void = { _ in }
    ) -> C {
        guard let cell = dequeueReusableCell(
            withIdentifier: C.name) as? C
        else {
            fatalError("Unable to dequeue cell of unregistered type \(C.name)")
        }
        configure(cell)
        return cell
    }
    
}

private extension UITableViewCell {
    
    class var name: String { String(describing: self) }
    
}

// MARK: - UIButton

extension UIButton {
    
    func addHandler(_ handler: @escaping () -> Void) {
        addAction(
            UIAction(handler: { _ in handler() }),
            for: .touchUpInside)
    }
    
    func addTarget(_ target: Any?, action: Selector) {
        addTarget(target, action: action, for: .touchUpInside)
    }
    
}
