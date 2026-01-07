
import Foundation
import Geometry
import Color
import Render

// MARK: - Public Types

public enum BrushMode {
    case paint
    case erase
}

public struct InputSample {
    
    public var updateID: Int?
    public var time: TimeInterval
    public var position: Vector
    
    public var pressure: Double
    public var altitude: Double
    public var azimuth: Vector
    public var roll: Double
    
    public var estimationFlags: InputSampleEstimationFlags
    
    public init(
        updateID: Int?,
        time: TimeInterval,
        position: Vector,
        pressure: Double,
        altitude: Double,
        azimuth: Vector,
        roll: Double,
        estimationFlags: InputSampleEstimationFlags
    ) {
        self.updateID = updateID
        self.time = time
        self.position = position
        self.pressure = pressure
        self.altitude = altitude
        self.azimuth = azimuth
        self.roll = roll
        self.estimationFlags = estimationFlags
    }
    
}

public struct InputSampleEstimationFlags {
    public var pressure: Bool
    public var altitude: Bool
    public var azimuth: Bool
    public var roll: Bool
    
    public init(
        pressure: Bool,
        altitude: Bool,
        azimuth: Bool,
        roll: Bool
    ) {
        self.pressure = pressure
        self.altitude = altitude
        self.azimuth = azimuth
        self.roll = roll
    }
    
    public var hasEstimatedValues: Bool {
        pressure ||
        altitude ||
        azimuth ||
        roll
    }
}

public struct InputSampleUpdate {
    
    public var updateID: Int
    public var pressure: Double?
    public var altitude: Double?
    public var azimuth: Vector?
    public var roll: Double?
    
    public init(
        updateID: Int,
        pressure: Double?,
        altitude: Double?,
        azimuth: Vector?,
        roll: Double?
    ) {
        self.updateID = updateID
        self.pressure = pressure
        self.altitude = altitude
        self.azimuth = azimuth
        self.roll = roll
    }
    
}

// MARK: - Samples

struct IntermediateSample {
    
    var time: TimeInterval
    var position: Vector
    var pressure: Double
    var altitude: Double
    var azimuth: Complex
    var roll: Complex
    
}

struct StrokeSample {

    var position: Vector
    var tangent: Vector
    var strokeDistance: Double

    var stampOffset: Vector
    var stampSize: Double
    var stampRotation: Complex
    var stampOpacity: Double

}

struct StrokeStamp {
    
    var sprite: BrushStampRenderer.Sprite
    
}

// MARK: - Batches

struct IntermediateSampleBatch {
    
    var samples: [IntermediateSample]
    var finalSampleTime: TimeInterval
    var isFinalBatch: Bool
    var isFinalized: Bool
    
}

struct StrokeSampleBatch {
    
    var samples: [StrokeSample]
    var isFinalBatch: Bool
    var isFinalized: Bool
    
}

struct StrokeStampBatch {
    
    var stamps: [StrokeStamp]
    var isFinalBatch: Bool
    var isFinalized: Bool
    
}

// MARK: - Interpolation

extension IntermediateSample: Interpolatable {
    
    static var zero: Self {
        .init(
            time: 0,
            position: .zero,
            pressure: 0,
            altitude: 0,
            azimuth: .zero,
            roll: .zero)
    }
    
    mutating func combine(
        value v: Self,
        weight w: Double
    ) {
        time     += w * v.time
        position += w * v.position
        pressure += w * v.pressure
        altitude += w * v.altitude
        azimuth  += w * v.azimuth
        roll     += w * v.roll
    }
    
}

extension StrokeSample: Interpolatable {
    
    static var zero: Self {
        .init(
            position: .zero,
            strokeDistance: 0,
            stampOffset: .zero,
            stampSize: 0,
            stampRotation: .zero,
            stampOpacity: 0)
    }
    
    mutating func combine(
        value v: Self,
        weight w: Double
    ) {
        position       += w * v.position
        strokeDistance += w * v.strokeDistance
        stampOffset    += w * v.stampOffset
        stampSize      += w * v.stampSize
        stampRotation  += w * v.stampRotation
        stampOpacity   += w * v.stampOpacity
    }
    
}
