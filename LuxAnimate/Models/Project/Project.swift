//
//  ProjectManifest.swift
//

import Foundation
import Geometry
import Color

enum Project {

    struct Manifest: Codable {
        var id: String
        var name: String
        var createdAt: Date

        var content: Content

        var assetIDs: Set<String>
    }

    struct Content: Codable {
        var metadata: ContentMetadata
        var layers: [Layer]
        var renderManifest: RenderManifest
    }

    struct ContentMetadata: Codable {
        var viewportSize: PixelSize
        var framesPerSecond: Int
        var frameCount: Int
        var backgroundColor: Color
    }

    struct Layer: Codable {
        var id: String
        var name: String

        var content: LayerContent
        var contentSize: PixelSize

        var transform: Matrix3
        var alpha: Double
    }

    enum LayerContent: Codable {
        case animation(AnimationLayerContent)
    }

    struct AnimationLayerContent: Codable {
        var drawings: [Drawing]
    }

    struct Drawing: Codable {
        var id: String
        var frameIndex: Int

        var fullAssetID: String?
        var thumbnailAssetID: String?
    }

    struct RenderManifest: Codable {
        var frameRenderManifests: [String: FrameRenderManifest]
        var frameRenderManifestFingerprintsByFrameIndex: [String]
    }

}

// MARK: - Asset IDs

extension Project.Manifest {

    mutating func updateAssetIDs() {
        assetIDs = getAssetIDs()
    }

    private func getAssetIDs() -> Set<String> {
        var assetIDs = Set<String>()

        for layer in content.layers {
            assetIDs.formUnion(layer.assetIDs())
        }

        return assetIDs
    }

}

extension Project.Layer {

    func assetIDs() -> Set<String> {
        switch content {
        case .animation(let content):
            return content.assetIDs()
        }
    }

}

extension Project.AnimationLayerContent {

    func assetIDs() -> Set<String> {
        var assetIDs = Set<String>()

        for drawing in drawings {
            assetIDs.formUnion(drawing.assetIDs())
        }

        return assetIDs
    }

}

extension Project.Drawing {

    func assetIDs() -> Set<String> {
        let assetIDs = [
            fullAssetID,
            thumbnailAssetID
        ]
        return Set(assetIDs.compactMap { $0 })
    }

}
