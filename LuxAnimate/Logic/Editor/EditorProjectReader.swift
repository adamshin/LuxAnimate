//
//  EditorProjectReader.swift
//

import Foundation

struct EditorProjectReader {
    
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()
    
    private func projectManifestURL(for projectURL: URL) -> URL {
        return projectURL.appending(path: "manifest")
    }
    
    func getProjectManifest(
        for projectURL: URL
    ) throws -> ProjectManifest {
        
        let projectManifestURL = projectManifestURL(
            for: projectURL)
        
        let data = try Data(contentsOf: projectManifestURL)
        return try decoder.decode(ProjectManifest.self, from: data)
    }
    
}
