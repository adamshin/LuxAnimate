
import Foundation
import Geometry

// TODO: Interpolate angular values correctly!
// (azimuth, roll)

struct SampleInterpolator {
    
    enum Error: Swift.Error {
        case emptyInput
        case incorrectWeightCount
        case zeroTotalWeight
    }
    
    static func interpolate(
        samples: [Sample],
        weights: [Double]
    ) throws -> Sample {
        
        guard !samples.isEmpty else {
            throw Error.emptyInput
        }
        guard samples.count == weights.count else {
            throw Error.incorrectWeightCount
        }
        
        let totalWeight = weights.reduce(0, +)
        guard totalWeight != 0 else {
            throw Error.zeroTotalWeight
        }
        
        var o = Sample(
            time: 0,
            position: .zero,
            pressure: 0,
            altitude: 0,
            azimuth: 0,
            roll: 0)
        
        for i in 0 ..< samples.count {
            let s = samples[i]
            let w = weights[i]
            
            let c = w / totalWeight
            
            o.time     += c * s.time
            o.position += c * s.position
            o.pressure += c * s.pressure
            o.altitude += c * s.altitude
            o.azimuth  += c * s.azimuth
            o.roll     += c * s.roll
        }
        return o
    }
    
    static func interpolate(
        strokeSamples samples: [StrokeSample],
        weights: [Double]
    ) throws -> StrokeSample {
        
        guard !samples.isEmpty else {
            throw Error.emptyInput
        }
        guard samples.count == weights.count else {
            throw Error.incorrectWeightCount
        }
        
        let totalWeight = weights.reduce(0, +)
        guard totalWeight != 0 else {
            throw Error.zeroTotalWeight
        }
        
        var o = StrokeSample(
            position: .zero,
            strokeDistance: 0,
            stampOffset: .zero,
            stampSize: 0,
            stampRotation: 0,
            stampAlpha: 0)
        
        for i in 0 ..< samples.count {
            let s = samples[i]
            let w = weights[i]
            
            let c = w / totalWeight
            
            o.position += c * s.position
            o.strokeDistance += c * s.strokeDistance
            o.stampOffset += c * s.stampOffset
            o.stampSize += c * s.stampSize
            o.stampRotation += c * s.stampRotation
            o.stampAlpha += c * s.stampAlpha
        }
        return o
    }
    
    static func interpolate2(
        strokeSample1 s1: StrokeSample,
        strokeSample2 s2: StrokeSample,
        weight1 w1: Double,
        weight2 w2: Double
    ) throws -> StrokeSample {
        
        let totalWeight = w1 + w2
        guard totalWeight != 0 else {
            throw Error.zeroTotalWeight
        }
        
        var o = StrokeSample(
            position: .zero,
            strokeDistance: 0,
            stampOffset: .zero,
            stampSize: 0,
            stampRotation: 0,
            stampAlpha: 0)
        
        // Sample 1
        let c1 = w1 / totalWeight
        o.position += c1 * s1.position
        o.strokeDistance += c1 * s1.strokeDistance
        o.stampOffset += c1 * s1.stampOffset
        o.stampSize += c1 * s1.stampSize
        o.stampRotation += c1 * s1.stampRotation
        o.stampAlpha += c1 * s1.stampAlpha
        
        // Sample 2
        let c2 = w2 / totalWeight
        o.position += c2 * s2.position
        o.strokeDistance += c2 * s2.strokeDistance
        o.stampOffset += c2 * s2.stampOffset
        o.stampSize += c2 * s2.stampSize
        o.stampRotation += c2 * s2.stampRotation
        o.stampAlpha += c2 * s2.stampAlpha
        
        return o
    }
    
}
