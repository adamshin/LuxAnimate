//
//  SceneRenderManifestBuilder.swift
//

import Foundation

struct SceneRenderManifestBuilder {
    
    static func build(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest
    ) -> Scene.RenderManifest {
        
        let frameIndexes = Array(0 ..< sceneManifest.frameCount)
        
        let frameSceneGraphs = FrameSceneGraphBuilder
            .build(
                projectManifest: projectManifest,
                sceneManifest: sceneManifest,
                frameIndexes: frameIndexes)
        
        var sceneRenderManifest = Scene.RenderManifest(
            frameRenderManifests: [:],
            frameRenderManifestFingerprintsByFrameIndex: [])
        
        for frameSceneGraph in frameSceneGraphs {
            let frameRenderManifest = FrameRenderManifest(
                frameSceneGraph: frameSceneGraph)
            
            let fingerprint = frameRenderManifest.fingerprint()
            
            sceneRenderManifest
                .frameRenderManifests[fingerprint]
                = frameRenderManifest
            
            sceneRenderManifest
                .frameRenderManifestFingerprintsByFrameIndex
                .append(fingerprint)
        }
        
        return sceneRenderManifest
    }
    
}
