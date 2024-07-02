//
//  RenderCacheManager.swift
//

import Foundation

class RenderCacheManager {
    
    private let projectID: String
    
    private let fileManager = FileManager.default
    private let fileURLHelper = FileURLHelper()
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        try createProjectRenderCacheDirectoryIfNeeded()
    }
    
    private func projectRenderCacheDirectoryURL()
    -> URL {
        fileURLHelper.renderCacheDirectoryURL()
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
