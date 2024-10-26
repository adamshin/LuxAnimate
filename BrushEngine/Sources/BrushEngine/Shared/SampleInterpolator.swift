
import Foundation
import Geometry

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
        
        // TODO: Interpolate angular values correctly!
        // (azimuth, roll)
        
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
        noiseSamples samples: [NoiseSample],
        weights: [Double]
    ) throws -> NoiseSample {
        
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
        
        var o = NoiseSample(
            sizeWobble: 0,
            offsetXWobble: 0,
            offsetYWobble: 0)
        
        for i in 0 ..< samples.count {
            let s = samples[i]
            let w = weights[i]
            
            let c = w / totalWeight
            
            o.sizeWobble    += c * s.sizeWobble
            o.offsetXWobble += c * s.offsetXWobble
            o.offsetYWobble += c * s.offsetYWobble
        }
        return o
    }
    
}
