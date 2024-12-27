//
//  AnimEditorFrameVC.swift
//

import UIKit

// What should this view controller contain?

// I think "workspace state" should live in the
// AnimEditorVC. This view controller should just handle
// tool state UI and controls, and report upwards.

// The AnimEditorVC can update workspace state based on
// the state of the frame VC and the timeline VC.

// The workspace state will hook into UI, but exist as
// a non-UI object. I think this makes more sense than
// being a view controller.

extension AnimEditorFrameVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onSelectBack(_ vc: AnimEditorFrameVC)
        
        func onRequestUndo(_ vc: AnimEditorFrameVC)
        func onRequestRedo(_ vc: AnimEditorFrameVC)
        
        func onRequestSceneEdit(
            _ vc: AnimEditorFrameVC,
            sceneEdit: ProjectEditBuilder.SceneEdit,
            editContext: Sendable?)
        
        func pendingEditAsset(
            _ vc: AnimEditorFrameVC,
            assetID: String
        ) -> ProjectEditManager.NewAsset?
        
    }
    
}

class AnimEditorFrameVC: UIViewController {
    
    private let bodyView = AnimEditorFrameView()
    
    private let toolbarVC = AnimEditorFrameToolbarVC()
    private let controlsVC = AnimEditorFrameControlsVC()
    
    // MARK: - Delegate
    
    weak var delegate: Delegate?
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(toolbarVC, to: bodyView.toolbarContainer)
        addChild(controlsVC, to: bodyView.contentContainer)
        
        toolbarVC.delegate = self
    }
    
    // MARK: - Interface
    
    func update(
        projectState: ProjectEditManager.State
    ) {
        toolbarVC.update(
            projectState: projectState)
    }
    
    var contentAreaView: UIView {
        bodyView.contentContainer
    }
    
}

// MARK: - Delegates

extension AnimEditorFrameVC:
    AnimEditorFrameToolbarVC.Delegate {
    
    func onSelectBack(_ vc: AnimEditorFrameToolbarVC) {
        delegate?.onSelectBack(self)
    }
    
    func onSelectUndo(_ vc: AnimEditorFrameToolbarVC) {
        delegate?.onRequestUndo(self)
    }
    
    func onSelectRedo(_ vc: AnimEditorFrameToolbarVC) {
        delegate?.onRequestRedo(self)
    }
    
    func onSelectTool(
        _ vc: AnimEditorFrameToolbarVC,
        tool: AnimEditorFrameToolbarVC.Tool,
        alreadySelected: Bool
    ) {
        // TODO
        toolbarVC.update(selectedTool: tool)
    }
    
}
