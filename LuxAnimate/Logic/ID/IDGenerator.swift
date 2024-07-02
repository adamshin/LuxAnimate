//
//  IDGenerator.swift
//

import Foundation

enum IDGenerator {
    
    static func id() -> String {
        let uuid = UUID()
        let data = withUnsafeBytes(of: uuid) { Data($0) }
        return encodedString(from: data)
    }
    
    private static func encodedString(from data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
}
