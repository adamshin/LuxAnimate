//
//  AnimEditorEditBuilder.swift
//

import Foundation

extension AnimEditorEditBuilder {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onRequestSceneEdit(
            _ b: AnimEditorEditBuilder,
            sceneEdit: ProjectEditBuilder.SceneEdit,
            editContext: Sendable?)
        
    }
    
}

@MainActor
class AnimEditorEditBuilder {
    
    weak var delegate: Delegate?
    
    private func apply(
        edit: AnimationLayerContentEditBuilder.Edit,
        state: AnimEditorState,
        editContext: Sendable?
    ) throws {
        
        let sceneEdit = try AnimationLayerContentEditBuilder
            .applyAnimationLayerContentEdit(
                sceneManifest: state.sceneManifest,
                layer: state.layer,
                layerContentEdit: edit)
        
        delegate?.onRequestSceneEdit(
            self,
            sceneEdit: sceneEdit,
            editContext: editContext)
    }
    
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
            state: state,
            editContext: nil)
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
            state: state,
            editContext: nil)
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
            state: state,
            editContext: nil)
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
            state: state,
            editContext: nil)
    }
    
    func editDrawing(
        state: AnimEditorState,
        drawingID: String,
        imageSet: DrawingAssetProcessor.ImageSet,
        editContext: Sendable?
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
            state: state,
            editContext: editContext)
    }
    
}
