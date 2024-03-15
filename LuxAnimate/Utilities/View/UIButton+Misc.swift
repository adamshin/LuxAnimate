//
//  UIButton+Misc.swift
//

import UIKit

extension UIButton {
    
    func addHandler(_ handler: @escaping () -> Void) {
        let action = UIAction(handler: { _ in handler() })
        addAction(action, for: .touchUpInside)
    }
    
}
