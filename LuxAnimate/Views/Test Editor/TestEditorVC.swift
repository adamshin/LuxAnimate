//
//  TestEditorVC.swift
//

import UIKit

// TODO: Figure out how all this should work?

// Scene state and renderer should live here maybe.
// As well as the main display link.

// Workspace vc should keep track of workspace transform.

// Should each tool exist as an object? Which installs
// itself into the view hierarchy?

// How far should the drawing editor logic be factored out?

// The process will need to look like:

// 1. Load the scene, including assets
// 2. Begin a drawing session. Allocate canvas texture
// 3. Instantiate the brush tool. Allocate memory, etc
// 4. Respond to edits and tool changes.

// The drawing editor logic shouldn't need to worry about
// loading, or about the rest of the scene. It should
// propagate updates back up to here, where we assemble
// the scene data and render everything.

// Maybe, when selecting a tool, we should:
// 1. Update the UI. Install new view controllers for
//    controls and gestures
// 2. Create a new tool editor object which manages the
//    internal logic of the tool
// 3. Pass the view controllers to the tool, so it can
//    hook itself up with delegates/references etc to
//    handle gestures and other inputs

// Second thought. Maybe the tool picker and tool control
// UI should exist at a higher level from the drawing
// editor itself. In the future, there will be a timeline
// vc as well for changing frames. We want the control UI
// to exist at a higher level instead of being recreated
// whenever the selected frame changes.

// Maybe the workspace view controller also lives at this
// higher level, as well as the tool gesture recognizers.
// Tool state UI would be managed at this level, and
// internal tool state would also be managed inside the
// drawing editor. The trick will be getting them to
// communicate properly.

class TestEditorVC: UIViewController {
    
    private let bodyView = TestEditorView()
    
    private let toolbarVC = TestEditorToolbarVC()
    private let toolControlsVC = TestEditorToolControlsVC()
    private let workspaceVC = TestEditorWorkspaceVC()
    
    private var toolState: TestEditorToolState?
    
    private var frameEditor: TestFrameEditor?
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let frameEditor = TestFrameEditor()
        frameEditor.delegate = self
        self.frameEditor = frameEditor
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
        
        updateSceneContentSize()
        selectBrushTool()
    }
    
    // MARK: - Content
    
    private func updateSceneContentSize() {
        let size = frameEditor?.getSceneContentSize()
            ?? PixelSize(0, 0)
        
        workspaceVC.setContentSize(Size(
            Double(size.width),
            Double(size.height)))
    }
    
    // MARK: - Tools
    
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
    }
    
    private func selectBrushTool() {
        enterToolState(TestEditorBrushToolState())
    }
    
    private func selectEraseTool() {
        enterToolState(TestEditorEraseToolState())
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
        // TODO: Do rendering here?
        // Maybe the frame editor should simply return a
        // scene object, which we draw.
        
        frameEditor?.onFrame(
            drawable: drawable,
            viewportSize: viewportSize,
            workspaceTransform: workspaceTransform)
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
    
    func onSelectBrushTool(_ vc: TestEditorToolbarVC) {
        selectBrushTool()
    }
    func onSelectEraseTool(_ vc: TestEditorToolbarVC) {
        selectEraseTool()
    }
    
    func onSelectUndo(_ vc: TestEditorToolbarVC) {
        clearCanvas()
    }
    func onSelectRedo(_ vc: TestEditorToolbarVC) { 
        clearCanvas()
    }
    
}

extension TestEditorVC: TestFrameEditorDelegate {
    
    func onChangeSceneContentSize(_ e: TestFrameEditor) {
        updateSceneContentSize()
    }
    
}
