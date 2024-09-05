//
//  RenderPreviewManager.swift
//

import Foundation

class RenderPreviewManager {
    
    private let projectID: String
    
    private let renderCacheManager: RenderCacheManager
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        renderCacheManager = try RenderCacheManager(
            projectID: projectID)
    }
    
    func update(projectManifest: Project.Manifest) {
        // Start rendering frames
        
        // I'll need to create a frame graph renderer.
        // Probably best to use the same logic for both
        // preview and full renders (configurable).
    }
    
}
