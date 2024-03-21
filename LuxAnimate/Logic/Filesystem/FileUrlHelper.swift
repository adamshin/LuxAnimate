//
//  FileUrlHelper.swift
//

import Foundation

struct FileUrlHelper {
    
    private let fileManager = FileManager.default
    
    let libraryDirectoryURL: URL
    let libraryManifestURL: URL
    
    let cacheDirectoryURL: URL
    
    init() {
        let documentDirectoryURL = try! fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        
        libraryDirectoryURL = documentDirectoryURL.appending(
            path: "library",
            directoryHint: .isDirectory)
        
        libraryManifestURL = libraryDirectoryURL.appending(
            path: "manifest")
        
        cacheDirectoryURL = try! fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
    }
    
    func projectURL(for projectID: String) -> URL {
        libraryDirectoryURL.appending(
            path: projectID,
            directoryHint: .isDirectory)
    }
    
    func projectManifestURL(for projectID: String) -> URL {
        projectURL(for: projectID)
            .appending(path: "manifest")
    }
    
    func projectCacheDirectoryURL(for projectID: String) -> URL {
        cacheDirectoryURL.appending(
            path: projectID,
            directoryHint: .isDirectory)
    }
    
}
