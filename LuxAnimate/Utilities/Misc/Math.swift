//
//  Math.swift
//

import Foundation

func clamp<T>(
    _ value: T, min lower: T, max upper: T
) -> T where T: Comparable {
    min(max(value, lower), upper)
}
