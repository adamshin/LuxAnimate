//
//  AnimEditorVC.swift
//

import UIKit

protocol AnimEditorVCDelegate: AnyObject {
    
    func onRequestUndo(_ vc: AnimEditorVC)
    func onRequestRedo(_ vc: AnimEditorVC)
    
    // TODO: Allow specifying synchronous vs asynchronous edits?
    // Should the async edit method take a completion handler?
    
    func onRequestApplyEdit(
        _ vc: AnimEditorVC,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditor.Asset])
    
}

class AnimEditorVC: UIViewController {
    
    private let bodyView = AnimEditorView()
    
    private let toolbarVC = AnimEditorToolbarVC()
    private let toolControlsVC = AnimEditorToolControlsVC()
    private let workspaceVC = EditorWorkspaceVC()
    
    private let assetLoader: AnimEditorAssetLoader
    
    private let workspaceRenderer = EditorWorkspaceRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
    private let projectID: String
    private let sceneID: String
    
    private var projectManifest: Project.Manifest?
    private var sceneManifest: Scene.Manifest?
    
    // TODO: Make these changeable.
    // Changing these values should reload the frame editor.
    private let activeLayerID: String
    private let activeFrameIndex: Int
    private let onionSkinConfig: AnimEditorOnionSkinConfig
    
    private var toolState: AnimEditorToolState?
    private var frameEditor: AnimFrameEditor?
    
    weak var delegate: AnimEditorVCDelegate?
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        activeLayerID: String,
        activeFrameIndex: Int
    ) {
        self.projectID = projectID
        self.sceneID = sceneID
        self.activeLayerID = activeLayerID
        self.activeFrameIndex = activeFrameIndex
        
        onionSkinConfig = AppConfig.onionSkinConfig
        
        assetLoader = AnimEditorAssetLoader(
            projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        assetLoader.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workspaceVC.delegate = self
        toolbarVC.delegate = self
        
        addChild(toolbarVC, to: bodyView.toolbarContainer)
        addChild(toolControlsVC, to: bodyView.toolControlsContainer)
        addChild(workspaceVC, to: bodyView.workspaceContainer)
        
        enterToolState(AnimEditorPaintToolState())
        
        reloadFrameEditor()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Logic
    
    private func reloadFrameEditor() {
        guard 
            let projectManifest,
            let sceneManifest,
            let toolState
        else { return }
        
        let frameEditor = AnimFrameEditor()
        frameEditor.delegate = self
        self.frameEditor = frameEditor
        
        frameEditor.begin(
            projectID: projectID,
            sceneID: sceneID,
            activeLayerID: activeLayerID,
            activeFrameIndex: activeFrameIndex,
            onionSkinConfig: onionSkinConfig,
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            editorToolState: toolState)
    }
    
    // MARK: - Tool State
    
    private func enterToolState(
        _ newToolState: AnimEditorToolState
    ) {
        toolState?.endState(
            workspaceVC: workspaceVC,
            toolControlsVC: toolControlsVC)
        
        toolState = newToolState
        
        newToolState.beginState(
            workspaceVC: workspaceVC,
            toolControlsVC: toolControlsVC)
        
        reloadFrameEditor()
    }
    
    // MARK: - Frame
    
    private func onFrame(
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: EditorWorkspaceTransform
    ) {
        let sceneGraph = frameEditor?.onFrame()
        
        if let sceneGraph {
            // Maybe only set this if it changes?
            workspaceVC.setContentSize(sceneGraph.contentSize)
            
            draw(
                drawable: drawable,
                viewportSize: viewportSize,
                workspaceTransform: workspaceTransform,
                sceneGraph: sceneGraph)
        }
    }
    
    // MARK: - Render
    
    private func draw(
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: EditorWorkspaceTransform,
        sceneGraph: EditorWorkspaceSceneGraph
    ) {
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        workspaceRenderer.draw(
            target: drawable.texture,
            commandBuffer: commandBuffer,
            viewportSize: viewportSize,
            workspaceTransform: workspaceTransform,
            sceneGraph: sceneGraph)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    // MARK: - Interface
    
    func update(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest
    ) {
        guard sceneManifest.layers
            .contains(where: { $0.id == activeLayerID })
        else {
            dismiss(animated: true)
            return
        }
        
        self.projectManifest = projectManifest
        self.sceneManifest = sceneManifest
        
        reloadFrameEditor()
    }
    
    func update(
        availableUndoCount: Int,
        availableRedoCount: Int
    ) {
        toolbarVC.update(
            availableUndoCount: availableUndoCount,
            availableRedoCount: availableRedoCount)
    }
    
}

// MARK: - Delegates

extension AnimEditorVC: AnimEditorToolbarVCDelegate {
    
    func onSelectBack(_ vc: AnimEditorToolbarVC) {
        dismiss(animated: true)
    }
    
    func onSelectUndo(_ vc: AnimEditorToolbarVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: AnimEditorToolbarVC) {
        delegate?.onRequestRedo(self)
    }
    
    func onSelectPaintTool(_ vc: AnimEditorToolbarVC) {
        enterToolState(AnimEditorPaintToolState())
    }
    func onSelectEraseTool(_ vc: AnimEditorToolbarVC) {
        enterToolState(AnimEditorEraseToolState())
    }
    
}

extension AnimEditorVC: EditorWorkspaceVCDelegate {
    
    func onFrame(
        _ vc: EditorWorkspaceVC,
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: EditorWorkspaceTransform
    ) {
        onFrame(
            drawable: drawable,
            viewportSize: viewportSize,
            workspaceTransform: workspaceTransform)
    }
    
    func onSelectUndo(_ vc: EditorWorkspaceVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: EditorWorkspaceVC) {
        delegate?.onRequestRedo(self)
    }
    
}

extension AnimEditorVC: AnimEditorAssetLoaderDelegate {
    
    func onLoadAsset(_ l: AnimEditorAssetLoader) {
        frameEditor?.onLoadAsset()
    }
    
    func onFinishLoadingAssets(_ l: AnimEditorAssetLoader) {
        frameEditor?.onFinishLoadingAssets()
    }
    
    func onError(_ l: AnimEditorAssetLoader) { }
    
}

extension AnimEditorVC: AnimFrameEditorDelegate {
    
    func workspaceViewSize(
        _ e: AnimFrameEditor
    ) -> Size {
        Size(workspaceVC.view.bounds.size)
    }
    
    func workspaceTransform(
        _ e: AnimFrameEditor
    ) -> EditorWorkspaceTransform {
        workspaceVC.workspaceTransform()
    }
    
    func setAssetLoaderAssetIDs(
        _ e: AnimFrameEditor,
        assetIDs: Set<String>
    ) {
        assetLoader.update(assetIDs: assetIDs)
    }
    
    func assetLoaderAssetTexture(
        _ e: AnimFrameEditor,
        assetID: String
    ) -> MTLTexture? {
        assetLoader.assetTexture(assetID: assetID)
    }
    
    func storeAssetLoaderTexture(
        _ e: AnimFrameEditor,
        assetID: String,
        texture: MTLTexture
    ) {
        assetLoader.storeAssetTexture(
            assetID: assetID,
            texture: texture)
    }
    
    func setEditInteractionEnabled(
        _ e: AnimFrameEditor,
        enabled: Bool
    ) {
        toolState?.setEditInteractionEnabled(enabled)
    }
    
    // For testing
    func editDrawing(
        _ e: AnimFrameEditor,
        drawingID: String,
        fullAssetID: String
    ) {
        guard let sceneManifest else { return }
        
        self.sceneManifest?.layers = sceneManifest.layers.map { layer in
            if case .animation(let content) = layer.content {
                let newDrawings = content.drawings.map { drawing in
                    if drawing.id == drawingID {
                        var newDrawing = drawing
                        newDrawing.assetIDs = Scene.DrawingAssetIDGroup(
                            full: fullAssetID, 
                            medium: "",
                            small: "")
                        return newDrawing
                    } else {
                        return drawing
                    }
                }
                var newContent = content
                newContent.drawings = newDrawings
                
                var newLayer = layer
                newLayer.content = .animation(newContent)
                return newLayer
                
            } else {
                return layer
            }
        }
    }
    
}
