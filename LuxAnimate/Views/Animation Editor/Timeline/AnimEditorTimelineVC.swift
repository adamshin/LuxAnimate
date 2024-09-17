//
//  AnimEditorTimelineVC.swift
//

import UIKit

extension AnimEditorTimelineVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onChangeContentAreaSize(
            _ vc: AnimEditorTimelineVC)
        
        func onChangeFocusedFrameIndex(
            _ vc: AnimEditorTimelineVC,
            _ focusedFrameIndex: Int)
        
        func onSelectPlayPause(
            _ vc: AnimEditorTimelineVC)
        
        func onRequestCreateDrawing(
            _ vc: AnimEditorTimelineVC,
            frameIndex: Int)
        
        func onRequestDeleteDrawing(
            _ vc: AnimEditorTimelineVC,
            frameIndex: Int)
        
        func onRequestInsertSpacing(
            _ vc: AnimEditorTimelineVC,
            frameIndex: Int)
        
        func onRequestRemoveSpacing(
            _ vc: AnimEditorTimelineVC,
            frameIndex: Int)
        
    }
    
}

class AnimEditorTimelineVC: UIViewController {
    
    weak var delegate: Delegate?
    
    private let collapsibleContentVC = EditorCollapsibleContentVC()
    
    private let toolbarVC = AnimEditorTimelineToolbarVC()
    private let trackVC = AnimEditorTimelineTrackVC()
    
    private let projectID: String
    
    private var model: AnimEditorTimelineModel = .empty
    private var focusedFrameIndex = 0
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneManifest: Scene.Manifest,
        layerContent: Scene.AnimationLayerContent,
        focusedFrameIndex: Int
    ) {
        self.projectID = projectID
        self.focusedFrameIndex = focusedFrameIndex
        
        super.init(nibName: nil, bundle: nil)
        
        update(
            sceneManifest: sceneManifest,
            layerContent: layerContent)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        collapsibleContentVC.delegate = self
        toolbarVC.delegate = self
        trackVC.delegate = self
        
        addChild(collapsibleContentVC, to: view)
        addChild(toolbarVC, to: collapsibleContentVC.barView)
        addChild(trackVC, to: collapsibleContentVC.collapsibleContentView)
        
        collapsibleContentVC.setExpanded(true, animated: false)
    }
    
    // MARK: - Menu
    
    private func showFrameMenu(frameIndex: Int) {
        guard let cell = trackVC.cell(at: frameIndex)
        else { return }
        
        let frame = model.frames[frameIndex]
        
        let contentView = EditorTimelineFrameMenuView(
            frameIndex: frameIndex,
            hasDrawing: frame.hasDrawing)
        
        let menu = EditorMenuView(
            contentView: contentView,
            presentation: .init(
                sourceView: cell,
                sourceViewEffect: .fade))
        
        contentView.delegate = self
        menu.delegate = self
        menu.present(in: self)
        
        trackVC.setOpenMenuFrameIndex(frameIndex)
    }
    
    // MARK: - Interface
    
    func update(
        sceneManifest: Scene.Manifest,
        layerContent: Scene.AnimationLayerContent
    ) {
        let model = AnimEditorTimelineModel.generate(
            projectID: projectID,
            sceneManifest: sceneManifest,
            layerContent: layerContent)
        
        self.model = model
        
        toolbarVC.setFrameCount(model.frames.count)
        trackVC.setModel(model)
    }
    
    func update(
        focusedFrameIndex: Int
    ) {
        self.focusedFrameIndex = focusedFrameIndex
        
        toolbarVC.setFocusedFrameIndex(focusedFrameIndex)
        trackVC.setFocusedFrameIndex(focusedFrameIndex)
    }
    
    func setExpanded(_ expanded: Bool) {
        collapsibleContentVC.setExpanded(
            expanded, animated: false)
    }
    
    var contentAreaView: UIView {
        collapsibleContentVC.contentAreaView
    }
    
}

// MARK: - Delegates

extension AnimEditorTimelineVC:
    EditorCollapsibleContentVCDelegate {
    
    func onSetExpanded(
        _ vc: EditorCollapsibleContentVC,
        _ expanded: Bool
    ) {
        toolbarVC.setExpanded(expanded)
    }
    
    func onChangeContentAreaSize(
        _ vc: EditorCollapsibleContentVC
    ) {
        delegate?.onChangeContentAreaSize(self)
    }
    
}

extension AnimEditorTimelineVC:
    AnimEditorTimelineToolbarVC.Delegate {
    
    func onChangeFocusedFrameIndex(
        _ vc: AnimEditorTimelineToolbarVC,
        _ focusedFrameIndex: Int
    ) {
        self.focusedFrameIndex = focusedFrameIndex
        trackVC.setFocusedFrameIndex(focusedFrameIndex)
        
        delegate?.onChangeFocusedFrameIndex(
            self, focusedFrameIndex)
    }
    
    func onSelectPlayPause(_ vc: AnimEditorTimelineToolbarVC) {
        delegate?.onSelectPlayPause(self)
    }
    
    func onSelectToggleExpanded(_ vc: AnimEditorTimelineToolbarVC) {
        collapsibleContentVC.toggleExpanded()
    }
    
}

extension AnimEditorTimelineVC:
    AnimEditorTimelineTrackVC.Delegate {
    
    func onBeginFrameScroll(_ vc: AnimEditorTimelineTrackVC) {
//        delegate?.onBeginFrameScroll(self)
    }
    func onEndFrameScroll(_ vc: AnimEditorTimelineTrackVC) {
//        delegate?.onEndFrameScroll(self)
    }
    
    func onChangeFocusedFrameIndex(
        _ vc: AnimEditorTimelineTrackVC,
        _ focusedFrameIndex: Int
    ) {
        self.focusedFrameIndex = focusedFrameIndex
        toolbarVC.setFocusedFrameIndex(focusedFrameIndex)
        
        delegate?.onChangeFocusedFrameIndex(
            self, focusedFrameIndex)
    }
    
    func onSelectFocusedFrame(
        _ vc: AnimEditorTimelineTrackVC,
        frameIndex: Int
    ) {
        let frame = model.frames[frameIndex]
        if !frame.hasDrawing {
            delegate?.onRequestCreateDrawing(self,
                frameIndex: frameIndex)
        }
    }
    
    func onLongPressFrame(
        _ vc: AnimEditorTimelineTrackVC,
        frameIndex: Int
    ) {
        showFrameMenu(frameIndex: frameIndex)
    }
    
}

extension AnimEditorTimelineVC:
    EditorMenuViewDelegate {
    
    func onPresent(_ v: EditorMenuView) { }
    
    func onDismiss(_ v: EditorMenuView) {
        trackVC.setOpenMenuFrameIndex(nil)
    }
    
}

extension AnimEditorTimelineVC:
    EditorTimelineFrameMenuViewDelegate {
    
    func onSelectCreateDrawing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        delegate?.onRequestCreateDrawing(self,
            frameIndex: frameIndex)
    }
    
    func onSelectDeleteDrawing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        delegate?.onRequestDeleteDrawing(self,
            frameIndex: frameIndex)
    }
    
    func onSelectInsertSpacing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        delegate?.onRequestInsertSpacing(self,
            frameIndex: frameIndex)
    }
    
    func onSelectRemoveSpacing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        delegate?.onRequestRemoveSpacing(self,
            frameIndex: frameIndex)
    }
    
}

