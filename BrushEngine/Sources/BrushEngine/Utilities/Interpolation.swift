
import Foundation

// MARK: - Interpolatable

protocol Interpolatable {
    
    static var zero: Self { get }
    mutating func combine(value: Self, weight: Double)
    
}

// MARK: - Interpolation Methods

enum InterpolationError: Error {
    case emptyInput
    case incorrectWeightCount
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
        throw InterpolationError.incorrectWeightCount
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
    _ pairs: (value: T, weight: Double)...
) throws -> T {
    
    guard !pairs.isEmpty else {
        throw InterpolationError.emptyInput
    }
    
    let totalWeight = pairs.reduce(0) { $0 + $1.weight }
    guard totalWeight != 0 else {
        throw InterpolationError.zeroTotalWeight
    }
    
    var result = T.zero
    for pair in pairs {
        result.combine(
            value: pair.value,
            weight: pair.weight / totalWeight)
    }
    return result
}
