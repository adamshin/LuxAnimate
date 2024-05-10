//
//  LayoutInvalidatingFlowLayout.swift
//

import UIKit

class LayoutInvalidatingFlowLayout: UICollectionViewFlowLayout {
    
    override func shouldInvalidateLayout(
        forBoundsChange newBounds: CGRect
    ) -> Bool {
        guard let collectionView else { return false }
        return collectionView.bounds.size != newBounds.size
    }
    
    override func invalidationContext(
        forBoundsChange newBounds: CGRect
    ) -> UICollectionViewLayoutInvalidationContext {
        
        guard let context = super.invalidationContext(forBoundsChange: newBounds) 
            as? UICollectionViewFlowLayoutInvalidationContext
        else {
            return UICollectionViewLayoutInvalidationContext()
        }
        guard let collectionView else {
            return context
        }
        context.invalidateFlowLayoutDelegateMetrics = 
            collectionView.bounds.size != newBounds.size
        
        return context
    }
    
}
