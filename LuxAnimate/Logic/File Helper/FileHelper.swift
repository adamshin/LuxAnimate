//
//  FileHelper.swift
//

import Foundation

struct FileHelper {
    
    static let projectLibraryManifestFileName = "projectLibraryManifest"
    static let projectManifestFileName = "projectManifest"
    
    private static var fileManager: FileManager {
        FileManager.default
    }
    
    static let shared = FileHelper()
    
    let projectLibraryDirectoryURL: URL
    let projectLibraryManifestURL: URL
    
    let brushLibraryDirectoryURL: URL
    
    let cacheDirectoryURL: URL
    
    init() {
        let documentDirectoryURL = try! Self.fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        
        projectLibraryDirectoryURL = documentDirectoryURL.appending(
            path: "projectLibrary",
            directoryHint: .isDirectory)
        
        projectLibraryManifestURL = projectLibraryDirectoryURL.appending(
            path: Self.projectLibraryManifestFileName)
        
        brushLibraryDirectoryURL = documentDirectoryURL.appending(
            path: "brushLibrary",
            directoryHint: .isDirectory)
        
        cacheDirectoryURL = try! Self.fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
    }
    
    func projectURL(for projectID: String) -> URL {
        projectLibraryDirectoryURL.appending(
            path: projectID,
            directoryHint: .isDirectory)
    }
    
    func projectManifestURL(for projectID: String) -> URL {
        projectURL(for: projectID).appending(
            path: Self.projectManifestFileName)
    }
    
    func editHistoryDirectoryURL() -> URL {
        cacheDirectoryURL.appending(
            path: "editHistory",
            directoryHint: .isDirectory)
    }
    
    func projectEditHistoryDirectoryURL(for projectID: String) -> URL {
        editHistoryDirectoryURL().appending(
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
