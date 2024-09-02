//
//  AnimEditorVC.swift
//

import UIKit

class AnimEditorVC: UIViewController {
    
    private let bodyView = AnimEditorView()
    
    private let toolbarVC = AnimEditorToolbarVC()
    private let toolControlsVC = AnimEditorToolControlsVC()
    private let workspaceVC = AnimEditorWorkspaceVC()
    
//    private let assetLoader: AnimEditorAssetLoader
    
    private let workspaceRenderer = AnimEditorWorkspaceRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
    private var toolState: AnimEditorToolState?
    
    private var frameEditor: AnimFrameEditor?
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
    
    // MARK: - Logic
    
    private func reloadFrameEditor() {
        // TODO: Reuse already-loaded assets from the
        // previous frame editor!
        
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
    
    // MARK: - Editing
    
    private func clearCanvas() {
        frameEditor?.clearCanvas()
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
    
}

// MARK: - Delegates

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
        clearCanvas()
    }
    func onSelectRedo(_ vc: AnimEditorWorkspaceVC) {
        clearCanvas()
    }
    
}

extension AnimEditorVC: AnimEditorToolbarVCDelegate {
    
    func onSelectBack(_ vc: AnimEditorToolbarVC) { }
    
    func onSelectUndo(_ vc: AnimEditorToolbarVC) {
        clearCanvas()
    }
    func onSelectRedo(_ vc: AnimEditorToolbarVC) { 
        clearCanvas()
    }
    
    func onSelectPaintTool(_ vc: AnimEditorToolbarVC) {
        enterToolState(AnimEditorPaintToolState())
    }
    func onSelectEraseTool(_ vc: AnimEditorToolbarVC) {
        enterToolState(AnimEditorEraseToolState())
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
