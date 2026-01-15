//
//  AnimEditorToolSettingsStore.swift
//

import Foundation

struct AnimEditorToolSettingsStore {
    
    enum Setting: String {
        case paintScale
        case paintSmoothing
        case eraseScale
        case eraseSmoothing
        
        var defaultValue: Double {
            switch self {
            case .paintScale: 0.2
            case .paintSmoothing: 0
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
    
    static var paintToolScale: Double {
        get { getDouble(for: .paintScale) }
        set { setDouble(newValue, for: .paintScale) }
    }
    
    static var paintToolSmoothing: Double {
        get { getDouble(for: .paintSmoothing) }
        set { setDouble(newValue, for: .paintSmoothing) }
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
