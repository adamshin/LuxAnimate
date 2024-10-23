//
//  BrushEngineSampleInterpolator.swift
//

import Foundation

struct BrushEngineSampleInterpolator {
    
    enum Error: Swift.Error {
        case emptyInput
        case zeroTotalWeight
    }
    
    static func interpolate(
        _ samplesAndWeights:
        [(sample: BrushEngine2.Sample, weight: Double)]
    ) throws -> BrushEngine2.Sample {
        
        // TODO: Interpolate angular values correctly!
        // (azimuth, roll)
        
        guard !samplesAndWeights.isEmpty else {
            throw Error.emptyInput
        }
        
        let totalWeight = samplesAndWeights
            .reduce(0, { $0 + $1.weight })
        
        guard totalWeight != 0 else {
            throw Error.zeroTotalWeight
        }
        
        var o = BrushEngine2.Sample(
            time: 0,
            position: .zero,
            pressure: 0,
            altitude: 0,
            azimuth: 0,
            roll: 0)
        
        for (s, w) in samplesAndWeights {
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
    
}
