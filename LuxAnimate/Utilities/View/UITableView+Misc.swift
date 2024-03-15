//
//  UITableView+Misc.swift
//

import UIKit

extension UITableView {
    
    func reconfigureVisibleCells() {
        UIView.performWithoutAnimation {
            reconfigureRows(at: indexPathsForVisibleRows ?? [])
        }
    }
    
}
