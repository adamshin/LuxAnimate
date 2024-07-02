//
//  FileHelper.swift
//

import Foundation

struct FileHelper {
    
    static let libraryManifestFileName = "libraryManifest"
    static let projectManifestFileName = "projectManifest"
    
    static let shared = FileHelper()
    
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
            path: Self.libraryManifestFileName)
        
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
        projectURL(for: projectID).appending(
            path: Self.projectManifestFileName)
    }
    
    func historyDirectoryURL() -> URL {
        cacheDirectoryURL.appending(
            path: "history",
            directoryHint: .isDirectory)
    }
    
    func projectHistoryDirectoryURL(for projectID: String) -> URL {
        historyDirectoryURL().appending(
            path: projectID,
            directoryHint: .isDirectory)
    }
    
    func renderCacheDirectoryURL() -> URL {
        cacheDirectoryURL.appending(
            path: "renderCache",
            directoryHint: .isDirectory)
    }
    
    func projectAssetURL(
        projectID: String,
        assetID: String
    ) -> URL {
        projectURL(for: projectID)
            .appending(path: assetID)
    }
    
}
