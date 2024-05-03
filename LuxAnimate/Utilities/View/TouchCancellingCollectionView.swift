//
//  TouchCancellingCollectionView.swift
//

import UIKit

class TouchCancellingCollectionView: UICollectionView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        true
    }
    
}
