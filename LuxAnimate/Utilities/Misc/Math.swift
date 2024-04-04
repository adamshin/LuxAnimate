//
//  Math.swift
//

import Foundation

func clamp<T>(
    _ value: T, min lower: T, max upper: T
) -> T where T: Comparable {
    min(max(value, lower), upper)
}

func wrap(_ value: Double, to range: Double) -> Double {
    let remainder = value.truncatingRemainder(dividingBy: range)
    return remainder < 0 ? remainder + range : remainder
}
