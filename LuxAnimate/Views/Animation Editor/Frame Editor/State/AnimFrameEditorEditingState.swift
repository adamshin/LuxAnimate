//
//  AnimFrameEditorEditingState.swift
//

import Metal

class AnimFrameEditorEditingState: AnimFrameEditorState {
    
    private let projectID: String
    private let sceneID: String
    private let activeLayerID: String
    private let activeFrameIndex: Int
    private let onionSkinConfig: AnimEditorOnionSkinConfig
    
    private let projectManifest: Project.Manifest
    private let sceneManifest: Scene.Manifest
    private let layer: Scene.Layer
    private let animationLayerContent: Scene.AnimationLayerContent
    
    private let frameSceneGraph: FrameSceneGraph
    
    private let activeDrawingManifest:
        AnimFrameEditorHelper.ActiveDrawingManifest
    
    private let assetManifest:
        AnimFrameEditorHelper.AssetManifest
    
    private let toolState: AnimFrameEditorToolState?
    
    private let workspaceSceneGraphGenerator = AnimFrameEditorWorkspaceSceneGraphGenerator()
    private var workspaceSceneGraph: EditorWorkspaceSceneGraph?
    
    weak var delegate: AnimFrameEditorStateDelegate?
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        activeLayerID: String,
        activeFrameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig,
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        animationLayerContent: Scene.AnimationLayerContent,
        editorToolState: AnimEditorToolState,
        frameSceneGraph: FrameSceneGraph,
        activeDrawingManifest: AnimFrameEditorHelper.ActiveDrawingManifest,
        assetManifest: AnimFrameEditorHelper.AssetManifest
    ) {
        self.projectID = projectID
        self.sceneID = sceneID
        self.activeLayerID = activeLayerID
        self.activeFrameIndex = activeFrameIndex
        self.onionSkinConfig = onionSkinConfig
        
        self.projectManifest = projectManifest
        self.sceneManifest = sceneManifest
        self.layer = layer
        self.animationLayerContent = animationLayerContent
        
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
    }
    
    func onFrame() -> EditorWorkspaceSceneGraph? {
        toolState?.onFrame()
        
        updateWorkspaceSceneGraph()
        return workspaceSceneGraph
    }
    
    func onLoadAsset() { }
    
}

// MARK: - Delegates

extension AnimFrameEditorEditingState: AnimFrameEditorToolStateDelegate {
    
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
    
}

extension AnimFrameEditorEditingState: AnimFrameEditorWorkspaceSceneGraphGeneratorDelegate {
    
    func assetTexture(
        _ g: AnimFrameEditorWorkspaceSceneGraphGenerator,
        assetID: String
    ) -> MTLTexture? {
        delegate?.assetLoaderAssetTexture(
            self, assetID: assetID)
    }
    
}
