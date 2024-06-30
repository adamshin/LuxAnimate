//
//  Sequence.swift
//

import Foundation

extension Sequence {
    
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        order: SortOrder = .forward
    ) -> [Element] {
        sorted(using: KeyPathComparator(keyPath, order: order))
    }
    
}
