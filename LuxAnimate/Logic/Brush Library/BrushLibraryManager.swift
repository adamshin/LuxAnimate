//
//  BrushLibraryManager.swift
//

import Foundation
import BrushEngine

private let defaultBrushesFileName = "DefaultBrushes.zip"

struct BrushLibraryManager {
    
    enum Error: Swift.Error {
        case brushLibraryDirectoryMissing
    }
    
    static func initialize() {
        guard let defaultBrushesURL = Bundle.main.url(
            forResource: defaultBrushesFileName,
            withExtension: nil)
        else { return }
        
        let brushLibraryDirectoryURL = FileHelper.shared
            .brushLibraryDirectoryURL
        
        // TODO: Extract zip file
        // Copy default brushes to brush folder
    }
    
    static func loadBrush(
        id: String
    ) throws -> Brush {
        
        let brushLibraryDirectoryURL =
            try brushLibraryDirectoryURL()
        
        let brushURL = brushLibraryDirectoryURL
            .appending(path: id)
        
        return try BrushLoader.loadBrush(
            id: id,
            url: brushURL,
            metalDevice: MetalInterface.shared.device)
    }
    
    private static func brushLibraryDirectoryURL()
    throws -> URL {
        guard let url = Bundle.main.url(
            forResource: "Brushes",
            withExtension: nil)
        else {
            throw Error.brushLibraryDirectoryMissing
        }
        return url
    }
    
}
