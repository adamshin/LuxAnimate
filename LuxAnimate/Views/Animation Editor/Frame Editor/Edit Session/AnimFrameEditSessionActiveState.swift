//
//  AnimFrameEditSessionActiveState.swift
//

import Foundation
import Geometry
import Metal

class AnimFrameEditSessionActiveState:
    AnimFrameEditSessionState {
    
    private let sceneGraph: AnimFrameEditorSceneGraph
    private let toolState: AnimFrameEditSessionToolState?
    
    private let workspaceSceneGraphBuilder
        = AnimFrameEditorWorkspaceSceneGraphBuilder()
    
    private var workspaceSceneGraph:
        EditorWorkspaceSceneGraph?
    
    weak var delegate: AnimFrameEditSessionStateDelegate?
    
    // MARK: - Init
    
    init(
        sceneGraph: AnimFrameEditorSceneGraph,
        editorToolState: AnimEditorToolState?
    ) {
        self.sceneGraph = sceneGraph
        
        let drawingCanvasSize = sceneGraph.layer.contentSize
        
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
        
        workspaceSceneGraphBuilder.delegate = self
    }
    
    // MARK: - Logic
    
    private func updateWorkspaceSceneGraph() {
        // TODO: Allow more customization from the tool?
        // Screen-space UI overlays, etc.
        
        // We should probably also draw the outline of the
        // selected layer.
        
        let activeDrawingTexture =
            toolState?.drawingCanvasTexture()
        
        workspaceSceneGraph = workspaceSceneGraphBuilder
            .build(
                sceneGraph: sceneGraph,
                activeDrawingTexture: activeDrawingTexture)
    }
    
    // MARK: - Interface
    
    func begin() {
        if let activeDrawing = sceneGraph
                .activeDrawingContext.activeDrawing,
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
        Size(sceneGraph.layer.contentSize)
    }

    func layerTransform(
        _ s: AnimFrameEditSessionToolState
    ) -> Matrix3 {
        sceneGraph.layer.transform
    }
    
    func onRequestEdit(
        _ s: AnimFrameEditSessionToolState,
        imageSet: DrawingAssetProcessor.ImageSet
    ) {
        guard let activeDrawing = sceneGraph
            .activeDrawingContext.activeDrawing
        else { return }

        delegate?.onRequestEdit(
            self,
            drawingID: activeDrawing.id,
            imageSet: imageSet)
    }
    
}

extension AnimFrameEditSessionActiveState:
    AnimFrameEditorWorkspaceSceneGraphBuilderDelegate {
    
    func assetTexture(
        _ g: AnimFrameEditorWorkspaceSceneGraphBuilder,
        assetID: String
    ) -> MTLTexture? {
        
        let asset = delegate?.asset(self, assetID: assetID)
        
        return asset?.texture
    }
    
}
