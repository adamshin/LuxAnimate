//
//  NewBrushStrokeEngineSampleResampler.swift
//

import Foundation

struct NewBrushStrokeEngineSampleResampler {
    
    enum Error: Swift.Error {
        case emptyInput
        case samplesNotSorted
        case resampleTimesNotSorted
    }
    
    /// Resamples a list of samples at the given points in
    /// time. The `samples` and `resampleTimes` parameters
    /// must both be sorted by time.
    ///
    /// The output array contains one output sample for each
    /// resample time.
    ///
    /// If a time falls in between two samples, the output
    /// sample is linearly interpolated between them.
    ///
    /// If a time falls outside the range of the input
    /// samples, the output sample is equal to the
    /// first/last sample.
    
    static func resample(
        samples: [BrushEngine2.Sample],
        resampleTimes: [TimeInterval]
    ) throws -> [BrushEngine2.Sample] {

        guard !samples.isEmpty, !resampleTimes.isEmpty
        else { throw Error.emptyInput }
        
//        guard samples.isSorted(by: { $0.time <= $1.time })
//        else { throw Error.samplesNotSorted }
//        
//        guard resampleTimes.isSorted(by: <=)
//        else { throw Error.resampleTimesNotSorted }
        
        var result = [BrushEngine2.Sample]()
        result.reserveCapacity(resampleTimes.count)
        
        // Handle resample times before first sample
        let firstSample = samples[0]
        while
            result.count < resampleTimes.count,
            resampleTimes[result.count] < firstSample.time
        {
            result.append(firstSample)
        }
        
        // Main interpolation loop
        var currentSampleIndex = 0
        while
            result.count < resampleTimes.count,
            currentSampleIndex < samples.count - 1
        {
            let currentResampleTime =
                resampleTimes[result.count]
            
            let s1 = samples[currentSampleIndex]
            let s2 = samples[currentSampleIndex + 1]
            
            if currentResampleTime < s2.time,
                s2.time > s1.time
            {
                let t = (currentResampleTime - s1.time)
                    / (s2.time - s1.time)
                
                let samplesAndWeights = [
                    (s1, 1 - t),
                    (s2, t)
                ]
                let sample = try!
                    BrushEngineSampleInterpolator
                        .interpolate(samplesAndWeights)
                
                result.append(sample)
                
            } else {
                currentSampleIndex += 1
            }
        }
        
        // Handle resample times after last sample
        let lastSample = samples[samples.count - 1]
        while result.count < resampleTimes.count {
            result.append(lastSample)
        }
        
        return result
    }
    
}
