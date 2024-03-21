//
//  ProjectManifestReader.swift
//

import Foundation

struct ProjectManifestReader {
    
    private let fileUrlHelper = FileUrlHelper()
    private let decoder = JSONDecoder()
    
    func getProjectManifest(
        for projectID: String
    ) throws -> ProjectManifest {
        
        let projectManifestURL = fileUrlHelper
            .projectManifestURL(for: projectID)
        
        let data = try Data(contentsOf: projectManifestURL)
        return try decoder.decode(ProjectManifest.self, from: data)
    }
    
}
