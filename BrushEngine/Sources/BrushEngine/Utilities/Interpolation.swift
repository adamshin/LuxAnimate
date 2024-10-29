
import Foundation

// MARK: - Interpolatable

protocol Interpolatable {
    
    static var zero: Self { get }
    mutating func combine(value: Self, weight: Double)
    
}

// MARK: - Interpolation Methods

enum InterpolationError: Error {
    case emptyInput
    case mismatchedInputCount
    case zeroTotalWeight
}

func interpolate<T: Interpolatable>(
    values: [T],
    weights: [Double]
) throws -> T {
    
    guard !values.isEmpty else {
        throw InterpolationError.emptyInput
    }
    guard values.count == weights.count else {
        throw InterpolationError.mismatchedInputCount
    }
    
    let totalWeight = weights.reduce(0, +)
    
    guard totalWeight != 0 else {
        throw InterpolationError.zeroTotalWeight
    }
    
    var result = T.zero
    for i in 0 ..< values.count {
        result.combine(
            value: values[i],
            weight: weights[i] / totalWeight)
    }
    return result
}

func interpolate<T: Interpolatable>(
    v0: T, v1: T,
    w0: Double, w1: Double
) throws -> T {
    
    let totalWeight = w0 + w1
    
    guard totalWeight != 0 else {
        throw InterpolationError.zeroTotalWeight
    }
    
    var result = T.zero
    result.combine(value: v0, weight: w0 / totalWeight)
    result.combine(value: v1, weight: w1 / totalWeight)
    
    return result
}

func interpolate<T: Interpolatable>(
    v0: T, v1: T, v2: T, v3: T,
    w0: Double, w1: Double, w2: Double, w3: Double
) throws -> T {
    
    let totalWeight = w0 + w1 + w2 + w3
    
    guard totalWeight != 0 else {
        throw InterpolationError.zeroTotalWeight
    }
    
    var result = T.zero
    result.combine(value: v0, weight: w0 / totalWeight)
    result.combine(value: v1, weight: w1 / totalWeight)
    result.combine(value: v2, weight: w2 / totalWeight)
    result.combine(value: v3, weight: w3 / totalWeight)
    
    return result
}
