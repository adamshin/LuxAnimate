//
//  AnimFrameEditor.swift
//

import Foundation
import Geometry

extension AnimFrameEditor {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func workspaceViewSize(_ e: AnimFrameEditor)
        -> Size
        
        func workspaceTransform(_ e: AnimFrameEditor)
        -> EditorWorkspaceTransform
        
        func loadAssets(
            _ e: AnimFrameEditor,
            assetIDs: Set<String>)
        
        func hasLoadedAssets(
            _ e: AnimFrameEditor,
            assetIDs: Set<String>
        ) -> Bool
        
        func asset(
            _ e: AnimFrameEditor,
            assetID: String
        ) -> AnimEditorAssetLoader.LoadedAsset?
        
        func onRequestEdit(
            _ e: AnimFrameEditor,
            drawingID: String,
            imageSet: DrawingAssetProcessor.ImageSet)
        
    }
    
    struct UpdateContext {
        var ignoreUpdate: Bool
    }
    
}

@MainActor
class AnimFrameEditor {
    
    private var editSession: AnimFrameEditSession?
    
    private var updateContext: UpdateContext?
    
    weak var delegate: Delegate?
    
    // MARK: - Update Context
    
    private func withUpdateContext(
        _ updateContext: UpdateContext,
        _ block: () -> Void
    ) {
        self.updateContext = updateContext
        block()
        self.updateContext = nil
    }
    
    // MARK: - Interface
    
    func update(
        model: AnimEditorModel,
        focusedFrameIndex: Int,
        editorToolState: AnimEditorToolState?
    ) {
        if let updateContext, updateContext.ignoreUpdate {
            return
        }
        
        editSession = AnimFrameEditSession(
            projectManifest: model.projectManifest,
            sceneManifest: model.sceneManifest,
            layer: model.layer,
            layerContent: model.layerContent,
            frameIndex: focusedFrameIndex,
            editorToolState: editorToolState,
            delegate: self)
    }
    
    func onFrame() -> EditorWorkspaceSceneGraph? {
        editSession?.onFrame()
    }
    
    func onAssetLoaderUpdate() {
        editSession?.onAssetLoaderUpdate()
    }
    
}

// MARK: - Delegates

extension AnimFrameEditor: AnimFrameEditSession.Delegate {
    
    func workspaceViewSize(
        _ s: AnimFrameEditSession
    ) -> Geometry.Size {
        delegate?.workspaceViewSize(self) ?? .zero
    }
    
    func workspaceTransform(
        _ s: AnimFrameEditSession
    ) -> EditorWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func loadAssets(
        _ s: AnimFrameEditSession,
        assetIDs: Set<String>
    ) {
        delegate?.loadAssets(self, assetIDs: assetIDs)
    }
    
    func hasLoadedAssets(
        _ s: AnimFrameEditSession,
        assetIDs: Set<String>
    ) -> Bool {
        delegate?.hasLoadedAssets(
            self, assetIDs: assetIDs) ?? false
    }
    
    func asset(
        _ s: AnimFrameEditSession,
        assetID: String
    ) -> AnimEditorAssetLoader.LoadedAsset? {
        delegate?.asset(self, assetID: assetID)
    }
    
    func onRequestEdit(
        _ s: AnimFrameEditSession,
        drawingID: String,
        imageSet: DrawingAssetProcessor.ImageSet
    ) {
        delegate?.onRequestEdit(
            self,
            drawingID: drawingID,
            imageSet: imageSet)
    }
    
}
