//
//  RenderManifestBuilder.swift
//

import Foundation

struct RenderManifestBuilder {

    static func build(
        projectManifest: Project.Manifest
    ) -> Project.RenderManifest {

        let frameCount = projectManifest.content.metadata.frameCount
        let frameIndexes = Array(0 ..< frameCount)

        let frameSceneGraphs = FrameSceneGraphBuilder
            .build(
                projectManifest: projectManifest,
                frameIndexes: frameIndexes)

        var renderManifest = Project.RenderManifest(
            frameRenderManifests: [:],
            frameRenderManifestFingerprintsByFrameIndex: [])

        for frameSceneGraph in frameSceneGraphs {
            let frameRenderManifest = FrameRenderManifest(
                frameSceneGraph: frameSceneGraph)

            let fingerprint = frameRenderManifest.fingerprint()

            renderManifest
                .frameRenderManifests[fingerprint]
                = frameRenderManifest

            renderManifest
                .frameRenderManifestFingerprintsByFrameIndex
                .append(fingerprint)
        }

        return renderManifest
    }

}
