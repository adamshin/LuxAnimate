//
//  BrushLibraryManager.swift
//

import Foundation
import BrushEngine
import ZIPFoundation

private let defaultBrushesFileName = "DefaultBrushes.zip"

struct BrushLibraryManager {
    
    enum Error: Swift.Error {
        case defaultBrushesDirectoryMissing
        case internalError
    }
    
    // MARK: - Initialization
    
    static func initialize() throws {
        try setupBrushLibraryDirectory()
        try setupDefaultBrushes()
    }
    
    private static func setupBrushLibraryDirectory() throws {
        let fileManager = FileManager.default
        
        let brushLibraryDirectoryURL = FileHelper.shared
            .brushLibraryDirectoryURL
        
        if fileManager.fileExists(
            atPath: brushLibraryDirectoryURL.path())
        {
            print("Removing existing brush library directory")
            try fileManager.removeItem(
                at: brushLibraryDirectoryURL)
        } else {
            print("Creating brush library directory")
            try fileManager.createDirectory(
                at: brushLibraryDirectoryURL,
                withIntermediateDirectories: true)
        }
    }
    
    private static func setupDefaultBrushes() throws {
        // TODO: Tidy this up?
        let fileManager = FileManager.default
        
        let brushLibraryDirectoryURL = FileHelper.shared
            .brushLibraryDirectoryURL
        
        let defaultBrushesURL = try defaultBrushesURL()
        try fileManager.unzipItem(
            at: defaultBrushesURL,
            to: brushLibraryDirectoryURL)
        
        let brushLibraryDirectoryContents = try fileManager
            .contentsOfDirectory(atPath: brushLibraryDirectoryURL.path())
            
        guard let tempDirName = brushLibraryDirectoryContents.first else {
            throw Error.internalError
        }
        let tempURLPath = brushLibraryDirectoryURL.appendingPathComponent(tempDirName).path()
        
        let contents = try fileManager.contentsOfDirectory(atPath: tempURLPath)
        
        for item in contents {
            let sourceURL = URL(fileURLWithPath: tempURLPath).appendingPathComponent(item)
            let destinationURL = URL(fileURLWithPath: brushLibraryDirectoryURL.path()).appendingPathComponent(item)
            try fileManager.moveItem(at: sourceURL, to: destinationURL)
        }
        try fileManager.removeItem(atPath: tempURLPath)
    }
    
    // MARK: - Brush Loading
    
    static func loadBrush(
        id: String
    ) throws -> Brush {
        
        let brushLibraryDirectoryURL =
            FileHelper.shared.brushLibraryDirectoryURL
        
        let brushURL = brushLibraryDirectoryURL
            .appending(path: id)
        
        return try BrushLoader.loadBrush(
            id: id,
            url: brushURL,
            metalDevice: MetalInterface.shared.device)
    }
    
    // MARK: - URLS
    
    private static func defaultBrushesURL()
    throws -> URL {
        guard let url = Bundle.main.url(
            forResource: "DefaultBrushes",
            withExtension: "zip")
        else {
            throw Error.defaultBrushesDirectoryMissing
        }
        return url
    }
    
}
