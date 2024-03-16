//
//  ProjectManifest.swift
//

import Foundation

struct ProjectManifest: Codable {
    
    var name: String
    
    var createdAt: Date
    var modifiedAt: Date
    
    var canvasSize: PixelSize
    
    var image: String?
    
}
