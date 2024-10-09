//
//  BrushStrokeEngineInputQueueTests.swift
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

struct BrushStrokeEngineInputQueueTests {

    @Test func test1() throws {
        let queue = BrushStrokeEngineInputQueue()
        
        queue.handleInputUpdate(
            addedSamples: (0..<5).map { _ in
                createInputSample()
            },
            predictedSamples: [])
        
        let output1 = queue.process()
        try #require(output1.count == 5)
        try #require(output1.allSatisfy { $0.isFinalized })
        
        let output2 = queue.process()
        try #require(output2.count == 0)
    }
    
    @Test func test2() throws {
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
        try #require(output1.count == 8)
        try #require(output1[0..<5].allSatisfy { $0.isFinalized })
        try #require(output1[5..<8].allSatisfy { !$0.isFinalized })
        
        queue.handleInputUpdate(
            addedSamples: (0..<6).map { _ in
                createInputSample()
            },
            predictedSamples: (0..<4).map { _ in
                createInputSample(
                    isPredicted: true)
            })
        
        let output2 = queue.process()
        try #require(output2.count == 10)
        try #require(output2[0..<6].allSatisfy { $0.isFinalized })
        try #require(output2[6..<10].allSatisfy { !$0.isFinalized })
        
        let output3 = queue.process()
        try #require(output3.count == 4)
        try #require(output3.allSatisfy { !$0.isFinalized })
    }
    
    @Test func test3() throws {
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
        try #require(output1.count == 10)
        try #require(output1[0..<1].allSatisfy { $0.isFinalized })
        try #require(output1[1..<10].allSatisfy { !$0.isFinalized })
        
        queue.handleInputUpdate(sampleUpdates: [
            BrushStrokeEngine2.InputSampleUpdate(
                updateID: 1,
                pressure: 0),
        ])
        // xEEEPPPPP
        
        let output2 = queue.process()
        // x|EEEPPPPP
        try #require(output2.count == 9)
        try #require(output2[0..<1].allSatisfy { $0.isFinalized })
        try #require(output2[1..<9].allSatisfy { !$0.isFinalized })
        
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
        try #require(output3.count == 7)
        try #require(output3.allSatisfy { !$0.isFinalized })
        
        queue.handleInputUpdate(sampleUpdates: [
            BrushStrokeEngine2.InputSampleUpdate(
                updateID: 2,
                pressure: 0),
        ])
        // xxxxPPP
        
        let output4 = queue.process()
        // xxxx|PPP
        try #require(output4.count == 7)
        try #require(output4[0..<4].allSatisfy { $0.isFinalized })
        try #require(output4[4..<7].allSatisfy { !$0.isFinalized })
        
        let output5 = queue.process()
        try #require(output5.count == 3)
        try #require(output5.allSatisfy { !$0.isFinalized })
    }
    
    @Test func test4() throws {
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
        try #require(output1.count == 10 + maxCount + 3)
        try #require(output1[0..<10].allSatisfy { $0.isFinalized })
        try #require(output1[10..<10 + maxCount + 3].allSatisfy { !$0.isFinalized })
        
        let output2 = queue.process()
        try #require(output2.count == maxCount + 3)
        try #require(output2.allSatisfy { !$0.isFinalized })
        
        queue.handleInputUpdate(
            addedSamples: (0..<5).map { _ in
                createInputSample(isPressureEstimated: true)
            },
            predictedSamples: [])
        
        let output3 = queue.process()
        try #require(output3.count == 5 + maxCount)
        try #require(output3[0..<5].allSatisfy { $0.isFinalized })
        try #require(output3[5..<5 + maxCount].allSatisfy { !$0.isFinalized })
    }
    
}
