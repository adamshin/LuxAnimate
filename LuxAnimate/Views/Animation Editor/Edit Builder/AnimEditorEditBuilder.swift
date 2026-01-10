//
//  AnimEditorEditBuilder.swift
//

import Foundation

struct AnimEditorEditBuilder {
    
    static func createDrawing(
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int
    ) throws -> ProjectEditBuilder.SceneEdit {
        
        let edit = try AnimationLayerContentEditBuilder
            .createDrawing(
                layerContent: layerContent,
                frameIndex: frameIndex)
        
        return try AnimationLayerContentEditBuilder
            .applyAnimationLayerContentEdit(
                sceneManifest: sceneManifest,
                layer: layer,
                layerContentEdit: edit)
    }
    
    static func deleteDrawing(
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int
    ) throws -> ProjectEditBuilder.SceneEdit {
        
        let edit = AnimationLayerContentEditBuilder
            .deleteDrawing(
                layerContent: layerContent,
                frameIndex: frameIndex)
        
        return try AnimationLayerContentEditBuilder
            .applyAnimationLayerContentEdit(
                sceneManifest: sceneManifest,
                layer: layer,
                layerContentEdit: edit)
    }
    
    static func insertSpacing(
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int
    ) throws -> ProjectEditBuilder.SceneEdit {
        
        let edit = AnimationLayerContentEditBuilder
            .insertSpacing(
                layerContent: layerContent,
                frameIndex: frameIndex)
        
        return try AnimationLayerContentEditBuilder
            .applyAnimationLayerContentEdit(
                sceneManifest: sceneManifest,
                layer: layer,
                layerContentEdit: edit)
    }
    
    static func removeSpacing(
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int
    ) throws -> ProjectEditBuilder.SceneEdit {
        
        let edit = try AnimationLayerContentEditBuilder
            .removeSpacing(
                layerContent: layerContent,
                frameIndex: frameIndex)
        
        return try AnimationLayerContentEditBuilder
            .applyAnimationLayerContentEdit(
                sceneManifest: sceneManifest,
                layer: layer,
                layerContentEdit: edit)
    }
    
    static func editDrawing(
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent,
        drawingID: String,
        imageSet: DrawingAssetProcessor.ImageSet
    ) throws -> ProjectEditBuilder.SceneEdit {
        
        let imageSet = AnimationLayerContentEditBuilder
            .DrawingImageSet(
                full: imageSet.full,
                thumbnail: imageSet.thumbnail)
        
        let edit = try AnimationLayerContentEditBuilder
            .editDrawing(
                layerContent: layerContent,
                drawingID: drawingID,
                imageSet: imageSet)
        
        return try AnimationLayerContentEditBuilder
            .applyAnimationLayerContentEdit(
                sceneManifest: sceneManifest,
                layer: layer,
                layerContentEdit: edit)
    }
    
}
