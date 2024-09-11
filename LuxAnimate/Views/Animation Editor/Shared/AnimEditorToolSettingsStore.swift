//
//  AnimEditorToolSettingsStore.swift
//

import Foundation

struct AnimEditorToolSettingsStore {
    
    enum Setting: String {
        case brushScale
        case brushSmoothing
        case eraseScale
        case eraseSmoothing
        
        var defaultValue: Double {
            switch self {
            case .brushScale: 0.2
            case .brushSmoothing: 0
            case .eraseScale: 0.2
            case .eraseSmoothing: 0
            }
        }
        
        var key: String {
            "AnimEditorToolSettingsStore.\(rawValue)Key"
        }
    }
    
    private static var defaults: UserDefaults {
        UserDefaults.standard
    }
    
    private static func getDouble(
        for setting: Setting
    ) -> Double {
        defaults.object(forKey: setting.key) as? Double
            ?? setting.defaultValue
    }
    
    private static func setDouble(
        _ value: Double,
        for setting: Setting
    ) {
        defaults.set(value, forKey: setting.key)
    }
    
    static var brushToolScale: Double {
        get { getDouble(for: .brushScale) }
        set { setDouble(newValue, for: .brushScale) }
    }
    
    static var brushToolSmoothing: Double {
        get { getDouble(for: .brushSmoothing) }
        set { setDouble(newValue, for: .brushSmoothing) }
    }
    
    static var eraseToolScale: Double {
        get { getDouble(for: .eraseScale) }
        set { setDouble(newValue, for: .eraseScale) }
    }
    
    static var eraseToolSmoothing: Double {
        get { getDouble(for: .eraseSmoothing) }
        set { setDouble(newValue, for: .eraseSmoothing) }
    }
}
