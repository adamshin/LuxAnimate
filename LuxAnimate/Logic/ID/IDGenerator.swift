//
//  IDGenerator.swift
//

import Foundation

enum IDGenerator {
    
    static func id() -> String {
        let uuid = UUID()
        let data = withUnsafeBytes(of: uuid) { Data($0) }
        return data.base64URLEncodedString()
    }
    
}
