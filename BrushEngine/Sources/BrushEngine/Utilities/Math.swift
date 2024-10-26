//
//  Math.swift
//

import Foundation

func clamp<T>(
    _ value: T, min lower: T, max upper: T
) -> T where T: Comparable {
    min(max(value, lower), upper)
}

func map<T: FloatingPoint>(
    _ value: T,
    in rangeA: (lower: T, upper: T),
    to rangeB: (lower: T, upper: T)
) -> T {
    let rangeASize = rangeA.upper - rangeA.lower
    let rangeBSize = rangeB.upper - rangeB.lower
    
    return rangeB.lower + (rangeBSize * (value - rangeA.lower) / rangeASize)
}

func wrap(_ value: Double, to range: Double) -> Double {
    let remainder = value.truncatingRemainder(dividingBy: range)
    return remainder < 0 ? remainder + range : remainder
}
