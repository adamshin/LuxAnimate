//
//  Array.swift
//

import Foundation

extension Array {
        
    func isSorted(
        by areInIncreasingOrder: (Element, Element) -> Bool
    ) -> Bool {
        guard count > 1 else { return true }
        
        for i in 1 ..< count {
            if !areInIncreasingOrder(self[i-1], self[i]) {
                return false
            }
        }
        return true
    }
    
}
