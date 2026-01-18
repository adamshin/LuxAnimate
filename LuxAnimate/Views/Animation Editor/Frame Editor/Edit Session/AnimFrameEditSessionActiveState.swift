//
//  AnimFrameEditSessionActiveState.swift
//

import Foundation
import Geometry
import Metal

class AnimFrameEditSessionActiveState:
    AnimFrameEditSessionState {
    
    private let projectManifest: Project.Manifest
    private let sceneManifest: Scene.Manifest
    private let layer: Scene.Layer
    private let layerContent: Scene.AnimationLayerContent
    private let frameIndex: Int
    private let editorToolState: AnimEditorToolState?

    private let editContext: AnimFrameEditContext
    
    private let toolState: AnimFrameEditSessionToolState?
    
    private let workspaceSceneGraphGenerator
        = AnimFrameEditorWorkspaceSceneGraphGenerator()
    
    private var workspaceSceneGraph:
        EditorWorkspaceSceneGraph?
    
    weak var delegate: AnimFrameEditSessionStateDelegate?
    
    // MARK: - Init
    
    init(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int,
        editorToolState: AnimEditorToolState?,
        editContext: AnimFrameEditContext
    ) {
        self.projectManifest = projectManifest
        self.sceneManifest = sceneManifest
        self.layer = layer
        self.layerContent = layerContent
        self.frameIndex = frameIndex
        self.editorToolState = editorToolState

        self.editContext = editContext
        
        let drawingCanvasSize = layer.contentSize
        
        if let editorToolState {
            switch editorToolState {
            case let state as AnimEditorPaintToolState:
                toolState = AnimFrameEditSessionPaintToolState(
                    editorToolState: state,
                    drawingCanvasSize: drawingCanvasSize)
                
            case let state as AnimEditorEraseToolState:
                toolState = AnimFrameEditSessionEraseToolState(
                    editorToolState: state,
                    drawingCanvasSize: drawingCanvasSize)
                
            default:
                toolState = nil
            }
        } else {
            toolState = nil
        }
        toolState?.delegate = self
        
        workspaceSceneGraphGenerator.delegate = self
    }
    
    // MARK: - Logic
    
    private func updateWorkspaceSceneGraph() {
        // TODO: Allow more customization from the tool?
        // Screen-space UI overlays, etc.

        // We should probably also draw the outline of the
        // selected layer.

        let activeDrawingTexture =
            toolState?.drawingCanvasTexture()

        workspaceSceneGraph = workspaceSceneGraphGenerator
            .generate(
                editContext: editContext,
                activeDrawingTexture: activeDrawingTexture)
    }
    
    // MARK: - Interface
    
    func begin() {
//        delegate?.setEditInteractionEnabled(
//            self, enabled: true)

        if let activeDrawing = editContext.activeDrawingContext.activeDrawing,
            let fullAssetID = activeDrawing.fullAssetID
        {
            let activeDrawingAsset = delegate?.asset(
                self, assetID: fullAssetID)

            if let texture = activeDrawingAsset?.texture {
                toolState?.setDrawingCanvasTextureContents(texture)
            }
        }

        updateWorkspaceSceneGraph()
    }
    
    func onFrame() -> EditorWorkspaceSceneGraph? {
        toolState?.onFrame()
        
        updateWorkspaceSceneGraph()
        
        return workspaceSceneGraph
    }
    
    func onAssetLoaderUpdate() { }
    
}

// MARK: - Delegates

extension AnimFrameEditSessionActiveState:
    AnimFrameEditSessionToolStateDelegate {
    
    func workspaceViewSize(
        _ s: AnimFrameEditSessionToolState
    ) -> Size {
        delegate?.workspaceViewSize(self) ?? .zero
    }
    
    func workspaceTransform(
        _ s: AnimFrameEditSessionToolState
    ) -> EditorWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func layerContentSize(
        _ s: AnimFrameEditSessionToolState
    ) -> Size {
        Size(layer.contentSize)
    }
    
    func layerTransform(
        _ s: AnimFrameEditSessionToolState
    ) -> Matrix3 {
        layer.transform
    }
    
    func onRequestEdit(
        _ s: AnimFrameEditSessionToolState,
        imageSet: DrawingAssetProcessor.ImageSet
    ) {
        guard let activeDrawing = editContext
            .activeDrawingContext.activeDrawing
        else { return }

        delegate?.onRequestEdit(
            self,
            drawingID: activeDrawing.id,
            imageSet: imageSet)
    }
    
}

extension AnimFrameEditSessionActiveState:
    AnimFrameEditorWorkspaceSceneGraphGeneratorDelegate {
    
    func assetTexture(
        _ g: AnimFrameEditorWorkspaceSceneGraphGenerator,
        assetID: String
    ) -> MTLTexture? {
        
        let asset = delegate?.asset(self, assetID: assetID)
        
        return asset?.texture
    }
    
}
