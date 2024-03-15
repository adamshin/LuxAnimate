//
//  UIViewController+Alert.swift
//

import UIKit

extension UIViewController {
    
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
