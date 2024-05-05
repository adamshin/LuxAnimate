//
//  EditorTimelineVC.swift
//

import UIKit

private let frameCount = 120
private let framesPerSecond = 24

protocol EditorTimelineVCDelegate: AnyObject {
    
    func onRequestCreateDrawing(
        _ vc: EditorTimelineVC,
        frameIndex: Int)
    
    func onChangeFocusedFrame(
        _ vc: EditorTimelineVC,
        index: Int)
    
    func onChangeConstraints(_ vc: EditorTimelineVC)
    
}

class EditorTimelineVC: UIViewController {
    
    weak var delegate: EditorTimelineVCDelegate?
    
    private let collapsibleBarVC = EditorTimelineCollapsibleBarVC()
    
    private let toolbarVC = TimelineToolbarVC()
    private let trackVC = TimelineTrackVC()
    
    private var model = EditorTimelineModel(frames: [])
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        initializeData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        collapsibleBarVC.delegate = self
        toolbarVC.delegate = self
        trackVC.delegate = self
        
        addChild(collapsibleBarVC, to: view)
        addChild(toolbarVC, to: collapsibleBarVC.barView)
        addChild(trackVC, to: collapsibleBarVC.collapsibleContentView)
        
        collapsibleBarVC.setExpanded(true, animated: false)
    }
    
    // MARK: - Data
    
    private func initializeData() {
        let frames: [EditorTimelineModel.Frame] = Array(
            repeating: .init(hasDrawing: false),
            count: 100)
        
        let model = EditorTimelineModel(frames: frames)
        setModel(model)
    }
    
    private func setModel(_ model: EditorTimelineModel) {
        self.model = model
        trackVC.setModel(model)
    }
    
    // MARK: - Logic
    
    private func createDrawing(frameIndex: Int) {
        guard model.frames.indices.contains(frameIndex),
            !model.frames[frameIndex].hasDrawing
        else { return }
        
        let frame = EditorTimelineModel.Frame(
            hasDrawing: true)
        
        var model = model
        model.frames[frameIndex] = frame
        
        setModel(model)
    }
    
    private func deleteDrawing(frameIndex: Int) {
        guard model.frames.indices.contains(frameIndex),
            model.frames[frameIndex].hasDrawing
        else { return }
        
        let frame = EditorTimelineModel.Frame(
            hasDrawing: false)
        
        var model = model
        model.frames[frameIndex] = frame
        
        setModel(model)
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
    
    var backgroundAreaView: UIView {
        collapsibleBarVC.backgroundAreaView
    }
    
}

// MARK: - Delegates

extension EditorTimelineVC: EditorTimelineCollapsibleBarVCDelegate {
    
    func onSetExpanded(
        _ vc: EditorTimelineCollapsibleBarVC,
        _ expanded: Bool
    ) {
        toolbarVC.setExpanded(expanded)
    }
    
    func onChangeConstraints(
        _ vc: EditorTimelineCollapsibleBarVC
    ) {
        delegate?.onChangeConstraints(self)
    }
    
}

extension EditorTimelineVC: TimelineToolbarVCDelegate {
    
    func onSelectPlay(_ vc: TimelineToolbarVC) { }
    
    func onSelectFirstFrame(_ vc: TimelineToolbarVC) {
        trackVC.focusFrame(
            at: 0,
            animated: false)
    }
    
    func onSelectLastFrame(_ vc: TimelineToolbarVC) {
        trackVC.focusFrame(
            at: frameCount - 1,
            animated: false)
    }
    
    func onSelectPreviousFrame(_ vc: TimelineToolbarVC) {
        trackVC.focusFrame(
            at: trackVC.focusedFrameIndex - 1,
            animated: false)
    }
    
    func onSelectNextFrame(_ vc: TimelineToolbarVC) {
        trackVC.focusFrame(
            at: trackVC.focusedFrameIndex + 1,
            animated: false)
    }
    
    func onSelectToggleExpanded(_ vc: TimelineToolbarVC) {
        collapsibleBarVC.toggleExpanded()
    }
    
}

extension EditorTimelineVC: TimelineTrackVCDelegate {
    
    func onSelectFocusedFrame(_ vc: TimelineTrackVC, index: Int) {
//        delegate?.onRequestCreateDrawing(self,
//            frameIndex: trackVC.focusedFrameIndex)
        
        createDrawing(frameIndex: index)
    }
    
    func onSelectFrame(_ vc: TimelineTrackVC, index: Int) {
        vc.focusFrame(at: index, animated: true)
    }
    
    func onLongPressFrame(_ vc: TimelineTrackVC, index: Int) {
        showFrameMenu(frameIndex: index)
    }
    
    func onChangeFocusedFrame(_ vc: TimelineTrackVC) {
        toolbarVC.updateFrameLabel(
            index: vc.focusedFrameIndex,
            total: frameCount)
        
        delegate?.onChangeFocusedFrame(self,
            index: vc.focusedFrameIndex)
    }
    
}

extension EditorTimelineVC: EditorMenuViewDelegate {
    
    func onPresent(_ v: EditorMenuView) { }
    
    func onDismiss(_ v: EditorMenuView) {
        trackVC.setOpenMenuFrameIndex(nil)
    }
    
}

extension EditorTimelineVC: EditorTimelineFrameMenuViewDelegate {
    
    func onSelectCreateDrawing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        createDrawing(frameIndex: frameIndex)
    }
    
    func onSelectDeleteDrawing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        deleteDrawing(frameIndex: frameIndex)
    }
    
}
