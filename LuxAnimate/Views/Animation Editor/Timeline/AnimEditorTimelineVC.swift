//
//  AnimEditorTimelineVC.swift
//

import UIKit

extension AnimEditorTimelineVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onChangeDrawerSize(
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
        
        func pendingAssetData(
            _ vc: AnimEditorTimelineVC,
            assetID: String
        ) -> Data?
        
    }
    
}

class AnimEditorTimelineVC: UIViewController {
    
    weak var delegate: Delegate?
    
    private let drawerVC = AnimEditorDrawerVC()
    private let toolbarVC = AnimEditorTimelineToolbarVC()
    private let trackVC = AnimEditorTimelineTrackVC()
    
    private let projectID: String
    
    private var timelineModel: AnimEditorTimelineModel = .empty
    private var focusedFrameIndex = 0
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        update(timelineModel: timelineModel)
        update(focusedFrameIndex: focusedFrameIndex)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        drawerVC.delegate = self
        toolbarVC.delegate = self
        trackVC.delegate = self
        
        addChild(drawerVC, to: view)
        addChild(toolbarVC, to: drawerVC.toolbar)
        addChild(trackVC, to: drawerVC.collapsibleContentView)
        
        drawerVC.setExpanded(false, animated: false)
    }
    
    // MARK: - Menu
    
    private func showFrameMenu(frameIndex: Int) {
        guard let cell = trackVC.cell(at: frameIndex)
        else { return }
        
        let frame = timelineModel.frames[frameIndex]
        
        let contentView = AnimEditorTimelineFrameMenuView(
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
        timelineModel: AnimEditorTimelineModel
    ) {
        self.timelineModel = timelineModel
        
        toolbarVC.setFrameCount(timelineModel.frames.count)
        trackVC.setTimelineModel(timelineModel)
    }
    
    func update(
        focusedFrameIndex: Int
    ) {
        self.focusedFrameIndex = focusedFrameIndex
        
        toolbarVC.setFocusedFrameIndex(focusedFrameIndex)
        trackVC.setFocusedFrameIndex(focusedFrameIndex)
    }
    
    func setExpanded(_ expanded: Bool) {
        drawerVC.setExpanded(
            expanded, animated: false)
    }
    
}

// MARK: - Delegates

extension AnimEditorTimelineVC:
    AnimEditorDrawerVCDelegate {
    
    func onSetExpanded(
        _ vc: AnimEditorDrawerVC,
        _ expanded: Bool
    ) {
        toolbarVC.setExpanded(expanded)
    }
    
    func onChangeDrawerSize(
        _ vc: AnimEditorDrawerVC
    ) {
        delegate?.onChangeDrawerSize(self)
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
        drawerVC.toggleExpanded()
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
        let frame = timelineModel.frames[frameIndex]
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
    
    func assetData(
        _ vc: AnimEditorTimelineTrackVC,
        assetID: String
    ) -> Data? {
        
        if let data = delegate?.pendingAssetData(
            self, assetID: assetID)
        {
            return data
            
        } else {
            let assetURL = FileHelper.shared
                .projectAssetURL(
                    projectID: projectID,
                    assetID: assetID)
            return try? Data(contentsOf: assetURL)
        }
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
    AnimEditorTimelineFrameMenuView.Delegate {
    
    func onSelectCreateDrawing(
        _ v: AnimEditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        delegate?.onRequestCreateDrawing(self,
            frameIndex: frameIndex)
    }
    
    func onSelectDeleteDrawing(
        _ v: AnimEditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        delegate?.onRequestDeleteDrawing(self,
            frameIndex: frameIndex)
    }
    
    func onSelectInsertSpacing(
        _ v: AnimEditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        delegate?.onRequestInsertSpacing(self,
            frameIndex: frameIndex)
    }
    
    func onSelectRemoveSpacing(
        _ v: AnimEditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        delegate?.onRequestRemoveSpacing(self,
            frameIndex: frameIndex)
    }
    
}
