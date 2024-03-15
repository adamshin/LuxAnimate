//
//  UITableView+Register.swift
//

import UIKit

extension UITableView {
    
    func register<C: UITableViewCell>(_ cellType: C.Type) {
        if let nib = C.nib() {
            register(nib, forCellReuseIdentifier: C.name)
        } else {
            register(cellType, forCellReuseIdentifier: C.name)
        }
    }
    
    func dequeue<C: UITableViewCell>(
        _ cellClass: C.Type,
        for indexPath: IndexPath
    ) -> C {
        return dequeueReusableCell(withIdentifier: cellClass.name, for: indexPath) as! C
    }
    
    func dequeue<C: UITableViewCell>(
        _ cellType: C.Type,
        configure: (C) -> Void = { _ in }
    ) -> C {
        guard let cell = dequeueReusableCell(withIdentifier: C.name) as? C else {
            fatalError("Attempting to dequeue cell of type \(C.name) which has not been registered!")
        }
        configure(cell)
        return cell
    }
    
}

private extension UITableViewCell {
    
    class var name: String {
        return String(describing: self)
    }
    
    class func nib() -> UINib? {
        let bundle = Bundle(for: self)
        if bundle.path(forResource: name, ofType: "nib") == nil { return nil }
        
        return UINib(nibName: name, bundle: bundle)
    }
    
}

