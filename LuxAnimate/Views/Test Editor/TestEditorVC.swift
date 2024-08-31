//
//  TestEditorVC.swift
//

import UIKit

class TestEditorVC: UIViewController {
    
    private let bodyView = TestEditorView()
    
    private let toolbarVC = TestEditorToolbarVC()
    private let toolControlsVC = TestEditorToolControlsVC()
    private let workspaceVC = TestEditorWorkspaceVC()
    
    private let workspaceRenderer = TestEditorWorkspaceRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
    private var toolState: TestEditorToolState?
    
    private var frameEditor: TestFrameEditor?
    
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
        
        enterToolState(TestEditorPaintToolState())
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
        
        let frameEditor = TestFrameEditor(
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
        _ newToolState: TestEditorToolState
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
        workspaceTransform: TestWorkspaceTransform
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
        workspaceTransform: TestWorkspaceTransform,
        scene: TestEditorScene
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

extension TestEditorVC: TestEditorWorkspaceVCDelegate {
    
    func onFrame(
        _ vc: TestEditorWorkspaceVC,
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: TestWorkspaceTransform
    ) {
        onFrame(
            drawable: drawable,
            viewportSize: viewportSize,
            workspaceTransform: workspaceTransform)
    }
    
    func onSelectUndo(_ vc: TestEditorWorkspaceVC) {
        clearCanvas()
    }
    func onSelectRedo(_ vc: TestEditorWorkspaceVC) {
        clearCanvas()
    }
    
}

extension TestEditorVC: TestEditorToolbarVCDelegate {
    
    func onSelectBack(_ vc: TestEditorToolbarVC) { }
    
    func onSelectUndo(_ vc: TestEditorToolbarVC) {
        clearCanvas()
    }
    func onSelectRedo(_ vc: TestEditorToolbarVC) { 
        clearCanvas()
    }
    
    func onSelectPaintTool(_ vc: TestEditorToolbarVC) {
        enterToolState(TestEditorPaintToolState())
    }
    func onSelectEraseTool(_ vc: TestEditorToolbarVC) {
        enterToolState(TestEditorEraseToolState())
    }
    
}

extension TestEditorVC: TestFrameEditorDelegate {
    
    func workspaceViewSize(
        _ e: TestFrameEditor
    ) -> Size {
        Size(workspaceVC.view.bounds.size)
    }
    
    func workspaceTransform(
        _ e: TestFrameEditor
    ) -> TestWorkspaceTransform {
        workspaceVC.workspaceTransform()
    }
    
    func onChangeSceneContentSize(_ e: TestFrameEditor) {
        updateWorkspaceContentSize()
    }
    
}
