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
        
        func onRequestSceneEdit(
            _ vc: AnimEditorTimelineVC,
            sceneEdit: ProjectEditBuilder.SceneEdit)
        
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
    
    private var contentViewModel: AnimEditorContentViewModel
    private var focusedFrameIndex: Int
    
    // MARK: - Init
    
    init(
        projectID: String,
        contentViewModel: AnimEditorContentViewModel,
        focusedFrameIndex: Int
    ) {
        self.projectID = projectID
        self.contentViewModel = contentViewModel
        self.focusedFrameIndex = focusedFrameIndex
        
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
        setupInitialState()
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
    
    private func setupInitialState() {
        update(contentViewModel: contentViewModel)
        update(focusedFrameIndex: focusedFrameIndex)
    }
    
    // MARK: - Menu
    
    private func showFrameMenu(frameIndex: Int) {
        // Does this belong here? Feels more... UI level.
        // Not business logic. Maybe should split concerns.
        guard let cell = trackVC.cell(at: frameIndex)
        else { return }
        
        let frame = contentViewModel
            .timelineViewModel
            .frames[frameIndex]
        
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
    
    // MARK: - Internal Logic
    
    private func createDrawing(frameIndex: Int) {
        do {
            let vm = contentViewModel
            
            let layerContentEdit =
                try AnimationLayerContentEditBuilder
                    .createDrawing(
                        layerContent: vm.layerContent,
                        frameIndex: frameIndex)
            
            let sceneEdit =
                try AnimationLayerContentEditBuilder
                    .applyAnimationLayerContentEdit(
                        sceneManifest: vm.sceneManifest,
                        layer: vm.layer,
                        layerContentEdit: layerContentEdit)
            
            delegate?.onRequestSceneEdit(self,
                sceneEdit: sceneEdit)
            
        } catch { }
    }
    
    private func deleteDrawing(frameIndex: Int) {
//        do {
//            let vm = contentViewModel
//            
//            let edit = try AnimEditorEditBuilder
//                .deleteDrawing(
//                    sceneManifest: vm.sceneManifest,
//                    layer: vm.layer,
//                    layerContent: vm.layerContent,
//                    frameIndex: frameIndex)
//            
//            delegate?.onRequestSceneEdit(
//                self, sceneEdit: edit)
//            
//        } catch { }
    }
    
    private func insertSpacing(frameIndex: Int) {
//        do {
//            let vm = contentViewModel
//            
//            let edit = try AnimEditorEditBuilder
//                .insertSpacing(
//                    sceneManifest: vm.sceneManifest,
//                    layer: vm.layer,
//                    layerContent: vm.layerContent,
//                    frameIndex: frameIndex)
//            
//            delegate?.onRequestSceneEdit(
//                self, sceneEdit: edit)
//            
//        } catch { }
    }
    
    private func removeSpacing(frameIndex: Int) {
//        do {
//            let vm = contentViewModel
//            
//            let edit = try AnimEditorEditBuilder
//                .removeSpacing(
//                    sceneManifest: vm.sceneManifest,
//                    layer: vm.layer,
//                    layerContent: vm.layerContent,
//                    frameIndex: frameIndex)
//            
//            delegate?.onRequestSceneEdit(
//                self, sceneEdit: edit)
//            
//        } catch { }
    }
    
    // MARK: - Interface

    func update(
        contentViewModel: AnimEditorContentViewModel
    ) {
        self.contentViewModel = contentViewModel
        
        toolbarVC.update(timelineViewModel: contentViewModel.timelineViewModel)
        trackVC.update(timelineViewModel: contentViewModel.timelineViewModel)
    }
    
    func update(
        focusedFrameIndex: Int
    ) {
        self.focusedFrameIndex = focusedFrameIndex
        
        toolbarVC.update(focusedFrameIndex: focusedFrameIndex)
        trackVC.update(focusedFrameIndex: focusedFrameIndex)
    }
    
    func setExpanded(_ expanded: Bool) {
        drawerVC.setExpanded(expanded, animated: false)
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
        delegate?.onChangeFocusedFrameIndex(
            self, focusedFrameIndex)
    }
    
    func onSelectPlayPause(
        _ vc: AnimEditorTimelineToolbarVC
    ) {
        delegate?.onSelectPlayPause(self)
    }
    
    func onSelectExpandToggle(
        _ vc: AnimEditorTimelineToolbarVC
    ) {
        drawerVC.toggleExpanded()
    }
    
}

extension AnimEditorTimelineVC:
    AnimEditorTimelineTrackVC.Delegate {
    
    func onBeginFrameScroll(
        _ vc: AnimEditorTimelineTrackVC) { }
    func onEndFrameScroll(
        _ vc: AnimEditorTimelineTrackVC) { }
    
    func onChangeFocusedFrameIndex(
        _ vc: AnimEditorTimelineTrackVC,
        _ focusedFrameIndex: Int
    ) {
        delegate?.onChangeFocusedFrameIndex(
            self, focusedFrameIndex)
    }
    
    func onSelectFocusedFrame(
        _ vc: AnimEditorTimelineTrackVC,
        frameIndex: Int
    ) {
        let frame = contentViewModel
            .timelineViewModel
            .frames[frameIndex]
        
        if !frame.hasDrawing {
            createDrawing(frameIndex: frameIndex)
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
        
        // TODO: Should this go through the asset loader,
        // or is this ok?
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
        createDrawing(frameIndex: frameIndex)
    }

    func onSelectDeleteDrawing(
        _ v: AnimEditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        deleteDrawing(frameIndex: frameIndex)
    }

    func onSelectInsertSpacing(
        _ v: AnimEditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        insertSpacing(frameIndex: frameIndex)
    }

    func onSelectRemoveSpacing(
        _ v: AnimEditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        removeSpacing(frameIndex: frameIndex)
    }

}
