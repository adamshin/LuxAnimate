//
//  LibraryManifest.swift
//

import Foundation

struct LibraryManifest: Codable {
    
    struct Project: Codable {
        var id: String
    }
    
    var projects: [Project]
    
    init() {
        projects = []
    }
    
}
