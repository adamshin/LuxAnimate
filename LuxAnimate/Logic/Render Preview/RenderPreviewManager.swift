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
        let previewManifest = RenderPreviewManifest.generate(
            projectManifest: projectManifest)
        
        // TODO: Re-render invalid frames
    }
    
}
