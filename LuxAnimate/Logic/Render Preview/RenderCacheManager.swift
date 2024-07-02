//
//  RenderCacheManager.swift
//

import Foundation

class RenderCacheManager {
    
    private let projectID: String
    
    private let fileManager = FileManager.default
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        try createProjectRenderCacheDirectoryIfNeeded()
    }
    
    private func projectRenderCacheDirectoryURL()
    -> URL {
        FileHelper.shared.renderCacheDirectoryURL()
            .appending(
                path: projectID,
                directoryHint: .isDirectory)
    }
    
    private func createProjectRenderCacheDirectoryIfNeeded()
    throws {
        let url = projectRenderCacheDirectoryURL()
        try fileManager.createDirectory(
            at: url,
            withIntermediateDirectories: false)
    }
    
}
