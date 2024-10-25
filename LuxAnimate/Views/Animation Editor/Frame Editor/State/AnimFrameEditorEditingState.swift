//
//  AnimFrameEditorEditingState.swift
//

import Metal
import Geometry

class AnimFrameEditorEditingState: AnimFrameEditorState {
    
    private let projectManifest: Project.Manifest
    private let sceneManifest: Scene.Manifest
    private let layer: Scene.Layer
    private let layerContent: Scene.AnimationLayerContent
    private let frameIndex: Int
    private let onionSkinConfig: AnimEditorOnionSkinConfig?
    private let editorToolState: AnimEditorToolState
    
    private let frameSceneGraph: FrameSceneGraph
    
    private let activeDrawingManifest:
        AnimFrameEditorHelper.ActiveDrawingManifest
    
    private let assetManifest:
        AnimFrameEditorHelper.AssetManifest
    
    private let toolState: AnimFrameEditorToolState?
    
    private let workspaceSceneGraphGenerator 
        = AnimFrameEditorWorkspaceSceneGraphGenerator()
    
    private var workspaceSceneGraph:
        EditorWorkspaceSceneGraph?
    
    weak var delegate: AnimFrameEditorStateDelegate?
    
    // MARK: - Init
    
    init(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig?,
        editorToolState: AnimEditorToolState,
        frameSceneGraph: FrameSceneGraph,
        activeDrawingManifest: AnimFrameEditorHelper.ActiveDrawingManifest,
        assetManifest: AnimFrameEditorHelper.AssetManifest
    ) {
        self.projectManifest = projectManifest
        self.sceneManifest = sceneManifest
        self.layer = layer
        self.layerContent = layerContent
        self.frameIndex = frameIndex
        self.onionSkinConfig = onionSkinConfig
        self.editorToolState = editorToolState
        
        self.frameSceneGraph = frameSceneGraph
        self.activeDrawingManifest = activeDrawingManifest
        self.assetManifest = assetManifest
        
        let drawingCanvasSize = layer.contentSize
        
        switch editorToolState {
        case let state as AnimEditorPaintToolState:
            toolState = AnimFrameEditorPaintToolState(
                editorToolState: state,
                drawingCanvasSize: drawingCanvasSize)
            
        case let state as AnimEditorEraseToolState:
            toolState = AnimFrameEditorEraseToolState(
                editorToolState: state,
                drawingCanvasSize: drawingCanvasSize)
            
        default:
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
                frameSceneGraph: frameSceneGraph,
                activeDrawingManifest: activeDrawingManifest,
                activeDrawingTexture: activeDrawingTexture,
                onionSkinConfig: onionSkinConfig)
    }
    
    // MARK: - Interface
    
    func beginState() {
        delegate?.setEditInteractionEnabled(
            self, enabled: true)
        
        if let activeDrawing = activeDrawingManifest.activeDrawing,
            let fullAssetID = activeDrawing.fullAssetID
        {
            let activeDrawingAsset = delegate?.assetLoaderAsset(
                self, assetID: fullAssetID)
            
            if let texture = activeDrawingAsset?.texture {
                toolState?.setDrawingCanvasTextureContents(texture)
            }
        }
        
        updateWorkspaceSceneGraph()
    }
    
    func onAssetLoaderUpdate() { }
    
    func onFrame() -> EditorWorkspaceSceneGraph? {
        toolState?.onFrame()
        
//        updateWorkspaceSceneGraph()
        
        return workspaceSceneGraph
    }
    
}

// MARK: - Delegates

extension AnimFrameEditorEditingState: 
    AnimFrameEditorToolStateDelegate {
    
    func workspaceViewSize(
        _ s: AnimFrameEditorToolState
    ) -> Size {
        delegate?.workspaceViewSize(self) ?? .zero
    }
    
    func workspaceTransform(
        _ s: AnimFrameEditorToolState
    ) -> EditorWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func layerContentSize(
        _ s: AnimFrameEditorToolState
    ) -> Size {
        Size(layer.contentSize)
    }
    
    func layerTransform(
        _ s: AnimFrameEditorToolState
    ) -> Matrix3 {
        layer.transform
    }
    
    func onEdit(
        _ s: AnimFrameEditorToolState,
        imageSet: DrawingAssetProcessor.ImageSet
    ) {
        guard let activeDrawing = activeDrawingManifest
            .activeDrawing
        else { return }
        
        delegate?.onEdit(
            self,
            drawingID: activeDrawing.id,
            imageSet: imageSet)
    }
    
}

extension AnimFrameEditorEditingState: 
    AnimFrameEditorWorkspaceSceneGraphGeneratorDelegate {
    
    func assetTexture(
        _ g: AnimFrameEditorWorkspaceSceneGraphGenerator,
        assetID: String
    ) -> MTLTexture? {
        
        let asset = delegate?.assetLoaderAsset(
            self, assetID: assetID)
        
        return asset?.texture
    }
    
}
