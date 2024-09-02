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
    private let workspaceVC = AnimEditorWorkspaceVC()
    
//    private let assetLoader: AnimEditorAssetLoader
    
    private let workspaceRenderer = AnimEditorWorkspaceRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
    private let projectID: String
    private let sceneID: String
    
    // TODO: Make these changeable
    private let activeLayerID: String
    private let activeFrameIndex: Int
    
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
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
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
        
        updateWorkspaceContentSize()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Logic
    
    private func reloadFrameEditor() {
        // TODO: Reuse already-loaded assets from the
        // previous frame editor!
        
        // Should we manually extract the drawing canvas
        // texture here? Maybe the frame editor should
        // store updated textures in the asset loader.
        
        let drawingCanvasTexture: MTLTexture?
        if let frameEditor {
            drawingCanvasTexture = frameEditor.drawingCanvasTexture()
        } else {
            drawingCanvasTexture = nil
        }
        
        guard let toolState else { return }
        
        let frameEditor = AnimFrameEditor(
            editorToolState: toolState,
            drawingCanvasTexture: drawingCanvasTexture)
        
        frameEditor.delegate = self
        
        self.frameEditor = frameEditor
    }
    
    private func updateWorkspaceContentSize() {
        guard let size = frameEditor?.sceneContentSize()
        else { return }
        
        workspaceVC.setContentSize(Size(
            Double(size.width),
            Double(size.height)))
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
        workspaceTransform: AnimWorkspaceTransform
    ) {
        let scene = frameEditor?.onFrame()
        
        if let scene {
            draw(
                drawable: drawable,
                viewportSize: viewportSize,
                workspaceTransform: workspaceTransform,
                scene: scene)
        }
    }
    
    // MARK: - Render
    
    private func draw(
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: AnimWorkspaceTransform,
        scene: AnimEditorScene
    ) {
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        workspaceRenderer.draw(
            target: drawable.texture,
            commandBuffer: commandBuffer,
            viewportSize: viewportSize,
            workspaceTransform: workspaceTransform,
            scene: scene)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    // MARK: - Interface
    
    func update(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest
    ) {
//        frameEditor = AnimationFrameEditor(
//            projectID: projectID,
//            sceneID: sceneID,
//            activeLayerID: activeLayerID,
//            activeFrameIndex: activeFrameIndex,
//            onionSkinPrevCount: 0,
//            onionSkinNextCount: 0,
//            projectManifest: projectManifest,
//            sceneManifest: sceneManifest,
//            delegate: self)
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

extension AnimEditorVC: AnimEditorWorkspaceVCDelegate {
    
    func onFrame(
        _ vc: AnimEditorWorkspaceVC,
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: AnimWorkspaceTransform
    ) {
        onFrame(
            drawable: drawable,
            viewportSize: viewportSize,
            workspaceTransform: workspaceTransform)
    }
    
    func onSelectUndo(_ vc: AnimEditorWorkspaceVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: AnimEditorWorkspaceVC) {
        delegate?.onRequestRedo(self)
    }
    
}

extension AnimEditorVC: AnimFrameEditorDelegate {
    
    func workspaceViewSize(
        _ e: AnimFrameEditor
    ) -> Size {
        Size(workspaceVC.view.bounds.size)
    }
    
    func workspaceTransform(
        _ e: AnimFrameEditor
    ) -> AnimWorkspaceTransform {
        workspaceVC.workspaceTransform()
    }
    
    func onChangeSceneContentSize(_ e: AnimFrameEditor) {
        updateWorkspaceContentSize()
    }
    
}
