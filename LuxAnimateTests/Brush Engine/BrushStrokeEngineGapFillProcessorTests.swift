//
//  BrushStrokeEngineGapFillProcessorTests.swift
//

import Testing
import Foundation

@testable import LuxAnimate

private func createSample(
    timeOffset: TimeInterval,
    isFinalized: Bool
) -> BrushEngine2.Sample {
    
    BrushEngine2.Sample(
        timeOffset: timeOffset,
        position: .zero,
        pressure: 0,
        altitude: 0,
        azimuth: 0,
        roll: 0,
        isFinalized: isFinalized)
}

struct BrushStrokeEngineGapFillProcessorTests {

    @Test func test1() throws {
        let step = BrushStrokeEngineGapFillProcessor.fillTimeInterval
        let p = BrushStrokeEngineGapFillProcessor()
        
        let input1 = (0..<5).map {
            createSample(
                timeOffset: Double($0) * step,
                isFinalized: true)
        }
        let output1 = p.process(input: input1, currentTimeOffset: 0)
        try #require(output1.count == 5)
        try #require(output1.allSatisfy { $0.isFinalized })
        
        let output2 = p.process(input: [], currentTimeOffset: 0)
        try #require(output2.count == 0)
        
        let input3 = (0..<10).map {
            createSample(
                timeOffset: Double($0) * step,
                isFinalized: $0 < 3)
        }
        let output3 = p.process(input: input3, currentTimeOffset: 0)
        try #require(output3.count == 10)
        try #require(output3[0..<3].allSatisfy { $0.isFinalized })
        try #require(output3[3..<10].allSatisfy { !$0.isFinalized })
    }
    
    @Test func test2() throws {
        let step1 =
            BrushStrokeEngineGapFillProcessor.fillTimeInterval
            * 1.4
        
        let step2 =
            BrushStrokeEngineGapFillProcessor.fillTimeInterval
            * 1.6
        
        let p = BrushStrokeEngineGapFillProcessor()
        
        let input1 = (0..<5).map {
            createSample(
                timeOffset: Double($0) * step1,
                isFinalized: true)
        }
        let output1 = p.process(input: input1, currentTimeOffset: 0)
        try #require(output1.count == 5)
        
        let input2 = (0..<5).map {
            createSample(
                timeOffset: Double($0) * step2,
                isFinalized: true)
        }
        let output2 = p.process(input: input2, currentTimeOffset: 0)
        try #require(output2.count == 9)
    }
    
    @Test func test3() throws {
        let step = BrushStrokeEngineGapFillProcessor.fillTimeInterval
        
        let p1 = BrushStrokeEngineGapFillProcessor()
        let output1 = p1.process(input: [], currentTimeOffset: 0)
        try #require(output1.count == 0)
        
        let p2 = BrushStrokeEngineGapFillProcessor()
        let input2 = (0..<1).map {
            createSample(
                timeOffset: Double($0) * step,
                isFinalized: true)
        }
        let output2 = p2.process(input: input2, currentTimeOffset: 0)
        try #require(output2.count == 1)
        
        let p3 = BrushStrokeEngineGapFillProcessor()
        let input3 = (0..<2).map {
            createSample(
                timeOffset: Double($0) * step,
                isFinalized: true)
        }
        let output3 = p3.process(input: input3, currentTimeOffset: 0)
        try #require(output3.count == 2)
    }
    
    @Test func test4() throws {
        let step = BrushStrokeEngineGapFillProcessor.fillTimeInterval
        let p = BrushStrokeEngineGapFillProcessor()
        
        let input1 = [
            createSample(timeOffset: 0*step, isFinalized: true),
            createSample(timeOffset: 1*step, isFinalized: true),
            createSample(timeOffset: 9*step, isFinalized: true),
        ]
        let output1 = p.process(input: input1, currentTimeOffset: 0)
        try #require(output1.count == 10)
        try #require(output1.allSatisfy { $0.isFinalized })
        
        let input2 = [
            createSample(timeOffset: 10*step, isFinalized: true),
            createSample(timeOffset: 15*step, isFinalized: true),
            createSample(timeOffset: 19*step, isFinalized: false),
        ]
        let output2 = p.process(input: input2, currentTimeOffset: 0)
        try #require(output2.count == 10)
        try #require(output2[0..<6].allSatisfy { $0.isFinalized })
        try #require(output2[6..<10].allSatisfy { !$0.isFinalized })
        
        let input3 = [
            createSample(timeOffset: 20*step, isFinalized: true),
            createSample(timeOffset: 21*step, isFinalized: false),
            createSample(timeOffset: 25*step, isFinalized: false),
        ]
        let output3 = p.process(input: input3, currentTimeOffset: 0)
        try #require(output3.count == 10)
        try #require(output3[0..<5].allSatisfy { $0.isFinalized })
        try #require(output3[5..<10].allSatisfy { !$0.isFinalized })
        
        let input4 = [
            createSample(timeOffset: 30*step, isFinalized: true),
            createSample(timeOffset: 35*step, isFinalized: false),
        ]
        let output4 = p.process(input: input4, currentTimeOffset: 0)
        try #require(output4.count == 15)
        try #require(output4[0..<10].allSatisfy { $0.isFinalized })
        try #require(output4[10..<15].allSatisfy { !$0.isFinalized })
        
        let input5 = [
            createSample(timeOffset: 35*step, isFinalized: true),
        ]
        let output5 = p.process(input: input5, currentTimeOffset: 0)
        try #require(output5.count == 5)
        try #require(output5.allSatisfy { $0.isFinalized })
    }
    
    @Test func test5() throws {
        let step = BrushStrokeEngineGapFillProcessor.fillTimeInterval
        let p = BrushStrokeEngineGapFillProcessor()
        
        let input1 = [
            createSample(timeOffset: 0*step, isFinalized: true)
        ]
        let output1 = p.process(input: input1, currentTimeOffset: 5*step)
        try #require(output1.count == 4)
        try #require(output1.allSatisfy { $0.isFinalized })
        
        let input2 = [
            createSample(timeOffset: 5*step, isFinalized: true)
        ]
        let output2 = p.process(input: input2, currentTimeOffset: 5*step)
        try #require(output2.count == 2)
        try #require(output2.allSatisfy { $0.isFinalized })
        
        let output3 = p.process(input: [], currentTimeOffset: 7*step)
        try #require(output3.count == 0)
        
        let output4 = p.process(input: [], currentTimeOffset: 8*step)
        try #require(output4.count == 1)
        try #require(output4.allSatisfy { $0.isFinalized })
        
        let output5 = p.process(input: [], currentTimeOffset: 10*step)
        try #require(output5.count == 2)
        try #require(output5.allSatisfy { $0.isFinalized })
        
        let input6 = [
            createSample(timeOffset: 10*step, isFinalized: false)
        ]
        let output6 = p.process(input: input6, currentTimeOffset: 15*step)
        try #require(output6.count == 5)
        try #require(output6.allSatisfy { !$0.isFinalized })
    }
    
}
