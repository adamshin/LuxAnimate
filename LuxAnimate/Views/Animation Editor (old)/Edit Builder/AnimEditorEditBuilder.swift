//
//  AnimEditorEditBuilder.swift
//

import Foundation

// TODO: Should this object have a delegate callback?
// Or should it just return an edit object? Probably the
// latter.

extension AnimEditorEditBuilder {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onRequestSceneEdit(
            _ b: AnimEditorEditBuilder,
            sceneEdit: ProjectEditBuilder.SceneEdit)
        
    }
    
}

@MainActor
class AnimEditorEditBuilder {
    
    weak var delegate: Delegate?
    
    // MARK: - Apply Edit
    
    private func apply(
        edit: AnimationLayerContentEditBuilder.Edit,
        state: AnimEditorState
    ) throws {
        
        let sceneEdit = try AnimationLayerContentEditBuilder
            .applyAnimationLayerContentEdit(
                sceneManifest: state.sceneManifest,
                layer: state.layer,
                layerContentEdit: edit)
        
        delegate?.onRequestSceneEdit(
            self,
            sceneEdit: sceneEdit)
    }
    
    // MARK: - Interface
    
    func createDrawing(
        state: AnimEditorState,
        frameIndex: Int
    ) throws {
        
        let edit = try AnimationLayerContentEditBuilder
            .createDrawing(
                layerContent: state.layerContent,
                frameIndex: frameIndex)
        
        try apply(
            edit: edit,
            state: state)
    }
    
    func deleteDrawing(
        state: AnimEditorState,
        frameIndex: Int
    ) throws {
        
        let edit = AnimationLayerContentEditBuilder
            .deleteDrawing(
                layerContent: state.layerContent,
                frameIndex: frameIndex)
        
        try apply(
            edit: edit,
            state: state)
    }
    
    func insertSpacing(
        state: AnimEditorState,
        frameIndex: Int
    ) throws {
        
        let edit = AnimationLayerContentEditBuilder
            .insertSpacing(
                layerContent: state.layerContent,
                frameIndex: frameIndex)
        
        try apply(
            edit: edit,
            state: state)
    }
    
    func removeSpacing(
        state: AnimEditorState,
        frameIndex: Int
    ) throws {
        
        let edit = try AnimationLayerContentEditBuilder
            .removeSpacing(
                layerContent: state.layerContent,
                frameIndex: frameIndex)
        
        try apply(
            edit: edit,
            state: state)
    }
    
    func editDrawing(
        state: AnimEditorState,
        drawingID: String,
        imageSet: DrawingAssetProcessor.ImageSet
    ) throws {
        
        let imageSet = AnimationLayerContentEditBuilder
            .DrawingImageSet(
                full: imageSet.full,
                thumbnail: imageSet.thumbnail)
        
        let edit = try AnimationLayerContentEditBuilder
            .editDrawing(
                layerContent: state.layerContent,
                drawingID: drawingID,
                imageSet: imageSet)
        
        try apply(
            edit: edit,
            state: state)
    }
    
}
