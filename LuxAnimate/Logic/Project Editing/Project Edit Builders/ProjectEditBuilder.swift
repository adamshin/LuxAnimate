//
//  ProjectEditBuilder.swift
//

import Foundation
import Color
import Geometry

private let newLayerContentSize = PixelSize(
    width: 1920, height: 1080)

struct ProjectEditBuilder {

    struct LayerEdit {
        var layerID: String
        var layer: Project.Layer
        var newAssets: [ProjectEditManager.NewAsset]
    }

    enum Error: Swift.Error {
        case invalidLayerID
    }

    // MARK: - Layer Edit

    static func applyLayerEdit(
        projectManifest: Project.Manifest,
        layerEdit: LayerEdit
    ) throws -> ProjectEditManager.Edit {

        guard let layerIndex = projectManifest.content.layers
            .firstIndex(where: { $0.id == layerEdit.layerID })
        else {
            throw Error.invalidLayerID
        }

        var projectManifest = projectManifest
        projectManifest.content.layers[layerIndex] = layerEdit.layer

        // Rebuild render manifest
        projectManifest.content.renderManifest =
            RenderManifestBuilder.build(projectManifest: projectManifest)

        projectManifest.updateAssetIDs()

        return ProjectEditManager.Edit(
            projectManifest: projectManifest,
            newAssets: layerEdit.newAssets)
    }

    // MARK: - Layer

    static func createLayer(
        projectManifest: Project.Manifest
    ) -> ProjectEditManager.Edit {

        let drawing = Project.Drawing(
            id: IDGenerator.id(),
            frameIndex: 0,
            fullAssetID: nil,
            thumbnailAssetID: nil)

        let drawings = [drawing]

        let animationLayerContent = Project.AnimationLayerContent(
            drawings: drawings)

        let transform = Matrix3.identity

        let layer = Project.Layer(
            id: IDGenerator.id(),
            name: "Animation Layer",
            content: .animation(animationLayerContent),
            contentSize: newLayerContentSize,
            transform: transform,
            alpha: 1)

        var projectManifest = projectManifest
        projectManifest.content.layers.append(layer)

        // Rebuild render manifest
        projectManifest.content.renderManifest =
            RenderManifestBuilder.build(projectManifest: projectManifest)

        projectManifest.updateAssetIDs()

        return ProjectEditManager.Edit(
            projectManifest: projectManifest,
            newAssets: [])
    }

    static func deleteLayer(
        projectManifest: Project.Manifest,
        layerID: String
    ) throws -> ProjectEditManager.Edit {

        guard let layerIndex = projectManifest.content.layers
            .firstIndex(where: { $0.id == layerID })
        else {
            throw Error.invalidLayerID
        }

        var projectManifest = projectManifest
        projectManifest.content.layers.remove(at: layerIndex)

        // Rebuild render manifest
        projectManifest.content.renderManifest =
            RenderManifestBuilder.build(projectManifest: projectManifest)

        projectManifest.updateAssetIDs()

        return ProjectEditManager.Edit(
            projectManifest: projectManifest,
            newAssets: [])
    }

}
