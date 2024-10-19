//
//  BrushStrokeEngineSampleInterpolator.swift
//

import Foundation

struct BrushStrokeEngineSampleInterpolator {
    
    static func interpolate(
        _ samplesAndWeights:
        [(sample: BrushEngine2.Sample, weight: Double)]
    ) -> BrushEngine2.Sample? {
        
        // TODO: Interpolate angular values correctly!
        // (azimuth, roll)
        
        guard !samplesAndWeights.isEmpty else { return nil }
        
        let totalWeight = samplesAndWeights
            .map { $0.weight }
            .reduce(0, +)
        
        guard totalWeight != 0 else { return nil }
        
        var o = BrushEngine2.Sample(
            timeOffset: 0,
            position: .zero,
            pressure: 0,
            altitude: 0,
            azimuth: 0,
            roll: 0,
            isFinalized: true)
        
        for (s, w) in samplesAndWeights {
            let c = w / totalWeight
            
            o.timeOffset += c * s.timeOffset
            o.position   += c * s.position
            o.pressure   += c * s.pressure
            o.altitude   += c * s.altitude
            o.azimuth    += c * s.azimuth
            o.roll       += c * s.roll
            
            o.isFinalized = o.isFinalized && s.isFinalized
        }
        return o
    }
    
}
