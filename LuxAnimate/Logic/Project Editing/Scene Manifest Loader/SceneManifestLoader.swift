//
//  SceneManifestLoader.swift
//

import Foundation

// TODO: Modify this to load asynchronously?

struct SceneManifestLoader {
    
    enum Error: Swift.Error {
        case invalidSceneID
        case invalidSceneManifest
    }
    
    static func load(
        projectManifest: Project.Manifest,
        sceneID: String
    ) throws -> Scene.Manifest {
        
        guard let sceneRef = projectManifest
            .content.sceneRefs
            .first(where: { $0.id == sceneID })
        else {
            throw Error.invalidSceneID
        }
        
        let sceneManifestURL = FileHelper.shared
            .projectAssetURL(
                projectID: projectManifest.id,
                assetID: sceneRef.manifestAssetID)
        
        do {
            let sceneManifestData = try Data(
                contentsOf: sceneManifestURL)
            
            let sceneManifest = try JSONFileDecoder
                .shared.decode(
                    Scene.Manifest.self,
                    from: sceneManifestData)
            
            return sceneManifest
            
        } catch {
            throw Error.invalidSceneManifest
        }
    }
    
}
