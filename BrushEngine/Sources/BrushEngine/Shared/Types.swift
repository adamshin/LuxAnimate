
import Foundation
import Geometry
    
enum BrushMode {
    case paint
    case erase
}

enum BlendMode {
    case normal
    case erase
}

struct InputSample {
    var updateID: Int?
    
    var time: TimeInterval
    var position: Vector
    
    var pressure: Double
    var altitude: Double
    var azimuth: Double
    var roll: Double
    
    var isPressureEstimated: Bool
    var isAltitudeEstimated: Bool
    var isAzimuthEstimated: Bool
    var isRollEstimated: Bool
    
    var hasEstimatedValues: Bool {
        isPressureEstimated ||
        isAltitudeEstimated ||
        isAzimuthEstimated ||
        isRollEstimated
    }
}

struct InputSampleUpdate {
    var updateID: Int
    
    var pressure: Double?
    var altitude: Double?
    var azimuth: Double?
    var roll: Double?
}

struct Sample {
    var time: TimeInterval
    
    var position: Vector
    var pressure: Double
    var altitude: Double
    var azimuth: Double
    var roll: Double
}

// TODO: Finish this
struct StrokePoint {
    var sample: Sample
    
    var strokeDistance: Double
    // TODO: Wobble distance, calculated separately?
    
    var taperScale: Double
    
    var sizeWobble: Double
    var offsetXWobble: Double
    var offsetYWobble: Double
}

struct NoiseSample {
    var sizeWobble: Double
    var offsetXWobble: Double
    var offsetYWobble: Double
}

struct Stamp {
    var position: Vector
    var size: Double
    var rotation: Double
    var alpha: Double
    var color: Color
    var offset: Vector
}
