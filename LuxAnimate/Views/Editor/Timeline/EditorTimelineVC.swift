//
//  EditorTimelineVC.swift
//

import UIKit

private let frameCount = 120
private let framesPerSecond = 24

protocol EditorTimelineVCDelegate: AnyObject {
    
    func onModifyConstraints(_ vc: EditorTimelineVC)
    
}

class EditorTimelineVC: UIViewController {
    
    weak var delegate: EditorTimelineVCDelegate?
    
    private let collapsibleBarVC = EditorTimelineCollapsibleBarVC()
    
    private let toolbarVC = TimelineToolbarVC()
    private let trackVC = TimelineTrackVC()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collapsibleBarVC.delegate = self
        toolbarVC.delegate = self
        trackVC.delegate = self
        
        addChild(collapsibleBarVC, to: view)
        addChild(toolbarVC, to: collapsibleBarVC.barView)
        addChild(trackVC, to: collapsibleBarVC.collapsibleContentView)
        
        collapsibleBarVC.setExpanded(true, animated: false)
        
        trackVC.setFrameCount(frameCount)
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
    
    func onModifyConstraints(
        _ vc: EditorTimelineCollapsibleBarVC
    ) {
        delegate?.onModifyConstraints(self)
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
    
    func onUpdateFocusedFrame(_ vc: TimelineTrackVC) {
        toolbarVC.updateFrameLabel(
            index: vc.focusedFrameIndex,
            total: frameCount)
    }
    
    func onSelectFrame(_ vc: TimelineTrackVC, index: Int) {
        vc.focusFrame(at: index, animated: true)
    }
    
}

extension EditorTimelineVC: EditorMenuViewDelegate {
    
    func onPresent(_ v: EditorMenuView) { }
    
    func onDismiss(_ v: EditorMenuView) {
        trackVC.setDotVisible(true)
    }
    
}
