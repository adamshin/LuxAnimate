
import Foundation
import Geometry
import Color

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
    public var azimuth: Double
    public var roll: Double
    
    public var isPressureEstimated: Bool
    public var isAltitudeEstimated: Bool
    public var isAzimuthEstimated: Bool
    public var isRollEstimated: Bool
    
    public var hasEstimatedValues: Bool {
        isPressureEstimated ||
        isAltitudeEstimated ||
        isAzimuthEstimated ||
        isRollEstimated
    }
    
    public init(
        updateID: Int?,
        time: TimeInterval,
        position: Vector,
        pressure: Double,
        altitude: Double,
        azimuth: Double,
        roll: Double,
        isPressureEstimated: Bool,
        isAltitudeEstimated: Bool,
        isAzimuthEstimated: Bool,
        isRollEstimated: Bool
    ) {
        self.updateID = updateID
        self.time = time
        self.position = position
        self.pressure = pressure
        self.altitude = altitude
        self.azimuth = azimuth
        self.roll = roll
        self.isPressureEstimated = isPressureEstimated
        self.isAltitudeEstimated = isAltitudeEstimated
        self.isAzimuthEstimated = isAzimuthEstimated
        self.isRollEstimated = isRollEstimated
    }
    
}

public struct InputSampleUpdate {
    
    public var updateID: Int
    public var pressure: Double?
    public var altitude: Double?
    public var azimuth: Double?
    public var roll: Double?
    
    public init(
        updateID: Int,
        pressure: Double?,
        altitude: Double?,
        azimuth: Double?,
        roll: Double?
    ) {
        self.updateID = updateID
        self.pressure = pressure
        self.altitude = altitude
        self.azimuth = azimuth
        self.roll = roll
    }
    
}

// MARK: - Internal Types

struct Sample {
    
    var time: TimeInterval
    var position: Vector
    var pressure: Double
    var altitude: Double
    var azimuth: Double
    var roll: Double
    
}

struct StrokeSample {
    
    var position: Vector
    var strokeDistance: Double
    
    var stampOffset: Vector
    var stampSize: Double
    var stampRotation: Double
    var stampAlpha: Double
    
}

struct StrokeStamp {
    
    var position: Vector
    var size: Double
    var rotation: Double
    var alpha: Double
    var color: Color
    
}

// MARK: - Interpolation

// TODO: Interpolate angular values correctly!
// (azimuth, roll)

extension Sample: Interpolatable {
    
    static var zero: Self {
        Sample(
            time: 0,
            position: .zero,
            pressure: 0,
            altitude: 0,
            azimuth: 0,
            roll: 0)
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
        StrokeSample(
            position: .zero,
            strokeDistance: 0,
            stampOffset: .zero,
            stampSize: 0,
            stampRotation: 0,
            stampAlpha: 0)
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
        stampAlpha     += w * v.stampAlpha
    }
    
}
