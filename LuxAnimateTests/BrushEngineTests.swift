//
//  BrushEngineTests.swift
//

import Testing
import Foundation

@testable import LuxAnimate

private func createInputSample(
    updateID: Int? = nil,
    timeOffset: TimeInterval = 0,
    isPredicted: Bool = false,
    isPressureEstimated: Bool = false
) -> BrushStrokeEngine2.InputSample {
    
    BrushStrokeEngine2.InputSample(
        isPredicted: isPredicted,
        updateID: updateID,
        timeOffset: timeOffset,
        position: .zero,
        pressure: 0,
        altitude: 0,
        azimuth: .zero,
        isPressureEstimated: isPressureEstimated,
        isAltitudeEstimated: false,
        isAzimuthEstimated: false)
}

struct BrushEngineTests {

    @Test func testInputQueue1() {
        let queue = BrushStrokeEngineInputQueue()
        
        queue.handleInputUpdate(
            addedSamples: (0..<5).map { _ in
                createInputSample()
            },
            predictedSamples: [])
        
        let output1 = queue.process()
        #expect(output1.finalizedSamples.count == 5)
        #expect(output1.unfinalizedSamples.count == 0)
        
        let output2 = queue.process()
        #expect(output2.finalizedSamples.count == 0)
        #expect(output2.unfinalizedSamples.count == 0)
    }
    
    @Test func testInputQueue2() {
        let queue = BrushStrokeEngineInputQueue()
        
        queue.handleInputUpdate(
            addedSamples: (0..<5).map { _ in
                createInputSample()
            },
            predictedSamples: (0..<3).map { _ in
                createInputSample(
                    isPredicted: true)
            })
        
        let output1 = queue.process()
        #expect(output1.finalizedSamples.count == 5)
        #expect(output1.unfinalizedSamples.count == 3)
        
        queue.handleInputUpdate(
            addedSamples: (0..<6).map { _ in
                createInputSample()
            },
            predictedSamples: (0..<4).map { _ in
                createInputSample(
                    isPredicted: true)
            })
        
        let output2 = queue.process()
        #expect(output2.finalizedSamples.count == 6)
        #expect(output2.unfinalizedSamples.count == 4)
        
        let output3 = queue.process()
        #expect(output3.finalizedSamples.count == 0)
        #expect(output3.unfinalizedSamples.count == 4)
    }
    
    @Test func testInputQueue3() {
        let queue = BrushStrokeEngineInputQueue()
        
        queue.handleInputUpdate(
            addedSamples: (0..<5).map {
                createInputSample(
                    updateID: $0,
                    isPressureEstimated: $0 >= 1)
            },
            predictedSamples: (0..<5).map { _ in
                createInputSample(
                    isPredicted: true)
            })
        // xEEEEPPPPP
        
        let output1 = queue.process()
        // x|EEEEPPPPP
        #expect(output1.finalizedSamples.count == 1)
        #expect(output1.unfinalizedSamples.count == 9)
        
        queue.handleInputUpdate(sampleUpdates: [
            BrushStrokeEngine2.InputSampleUpdate(
                updateID: 1,
                pressure: 0),
        ])
        // xEEEPPPPP
        
        let output2 = queue.process()
        // x|EEEPPPPP
        #expect(output2.finalizedSamples.count == 1)
        #expect(output2.unfinalizedSamples.count == 8)
        
        queue.handleInputUpdate(
            addedSamples: (0..<1).map { _ in
                createInputSample()
            },
            predictedSamples: (0..<3).map { _ in
                createInputSample(
                    isPredicted: true)
            })
        // EEExPPP
        
        queue.handleInputUpdate(sampleUpdates: [
            BrushStrokeEngine2.InputSampleUpdate(
                updateID: 3,
                pressure: 0),
            BrushStrokeEngine2.InputSampleUpdate(
                updateID: 4,
                pressure: 0),
        ])
        // ExxxPPP
        
        let output3 = queue.process()
        // |ExxxPPP
        #expect(output3.finalizedSamples.count == 0)
        #expect(output3.unfinalizedSamples.count == 7)
        
        queue.handleInputUpdate(sampleUpdates: [
            BrushStrokeEngine2.InputSampleUpdate(
                updateID: 2,
                pressure: 0),
        ])
        // xxxxPPP
        
        let output4 = queue.process()
        // xxxx|PPP
        #expect(output4.finalizedSamples.count == 4)
        #expect(output4.unfinalizedSamples.count == 3)
        
        let output5 = queue.process()
        #expect(output5.finalizedSamples.count == 0)
        #expect(output5.unfinalizedSamples.count == 3)
    }
    
    @Test func testInputQueue4() {
        let queue = BrushStrokeEngineInputQueue()
        
        let maxCount = BrushStrokeEngineInputQueue.maxInputSampleCount
        let count = maxCount + 10
        
        queue.handleInputUpdate(
            addedSamples: (0..<count).map { _ in
                createInputSample(isPressureEstimated: true)
            },
            predictedSamples: (0..<3).map { _ in
                createInputSample(isPredicted: true)
            })
        
        let output1 = queue.process()
        #expect(output1.finalizedSamples.count == 10)
        #expect(output1.unfinalizedSamples.count == maxCount + 3)
        
        let output2 = queue.process()
        #expect(output2.finalizedSamples.count == 0)
        #expect(output2.unfinalizedSamples.count == maxCount + 3)
        
        queue.handleInputUpdate(
            addedSamples: (0..<5).map { _ in
                createInputSample(isPressureEstimated: true)
            },
            predictedSamples: [])
        
        let output3 = queue.process()
        #expect(output3.finalizedSamples.count == 5)
        #expect(output3.unfinalizedSamples.count == maxCount)
    }
    
}
