//
//  AnimEditorFrameVC.swift
//

import UIKit

// I think this file gets killed. Frame editor logic can
// live inside a non-UI object.

extension AnimEditorFrameVC {
    
    enum Tool {
        case paint
        case erase
    }
    
}

extension AnimEditorFrameVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onSelectBack(_ vc: AnimEditorFrameVC)
        
        func onRequestUndo(_ vc: AnimEditorFrameVC)
        func onRequestRedo(_ vc: AnimEditorFrameVC)
        
        func onSelectTool(
            _ vc: AnimEditorFrameVC,
            tool: Tool)
        
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
    
//    private let toolbarVC = AnimEditor2ToolbarVC()
//    private let controlsVC = AnimEditorFrameControlsVC()
    
    private let toolStateManager = AnimEditorFrameToolStateManager()
    
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
        
//        toolbarVC.delegate = self
        
//        addChild(toolbarVC, to: bodyView.toolbarContainer)
//        addChild(controlsVC, to: bodyView.contentContainer)
        
        setSelectedTool(.paint)
    }
    
    // MARK: - Tools
    
    private func setSelectedTool(
        _ selectedTool: Tool
    ) {
//        toolbarVC.update(selectedTool: selectedTool)
//        controlsVC.update(selectedTool: selectedTool)
    }
    
    // MARK: - Interface
    
//    func update(
//        projectState: ProjectEditManager.State
//    ) {
//        toolbarVC.update(
//            projectState: projectState)
//    }
//    
//    var contentAreaView: UIView {
//        bodyView.contentContainer
//    }
//    
//    var selectedTool: Tool? {
//        toolbarVC.selectedTool
//    }
    
}

// MARK: - Delegates

//extension AnimEditorFrameVC:
//    AnimEditor2ToolbarVC.Delegate {
//    
//    func onSelectBack(_ vc: AnimEditor2ToolbarVC) {
//        delegate?.onSelectBack(self)
//    }
//    
//    func onSelectUndo(_ vc: AnimEditor2ToolbarVC) {
//        delegate?.onRequestUndo(self)
//    }
//    
//    func onSelectRedo(_ vc: AnimEditor2ToolbarVC) {
//        delegate?.onRequestRedo(self)
//    }
//    
//    func onSelectTool(
//        _ vc: AnimEditor2ToolbarVC,
//        tool: AnimEditorFrameVC.Tool,
//        isAlreadySelected: Bool
//    ) {
//        if isAlreadySelected {
//            controlsVC.showExpandedToolControls()
//        } else {
//            controlsVC.update(selectedTool: tool)
//            delegate?.onSelectTool(self, tool: tool)
//        }
//    }
//    
//}
