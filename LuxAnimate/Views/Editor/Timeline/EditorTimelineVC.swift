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
    
    private var isPlaying = false
    private var playbackTimer: Timer?
    
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
        addChild(trackVC, to: collapsibleBarVC.contentView)
        
        collapsibleBarVC.setExpanded(true, animated: false)
        
        trackVC.setFrameCount(frameCount)
    }
    
    // MARK: - Interface
    
    var remainderAreaView: UIView {
        collapsibleBarVC.remainderAreaView
    }
    
    private func startPlayback() {
        guard !isPlaying else { return }
        
        isPlaying = true
        toolbarVC.setPlayButtonPlaying(true)
        
        if trackVC.selectedFrameIndex == frameCount - 1 {
            trackVC.selectFrame(at: 0, animated: false)
        }
        
        playbackTimer = Timer.scheduledTimer(
            withTimeInterval: 1 / Double(framesPerSecond),
            repeats: true)
        { [weak self] _ in
            guard let self else { return }
            
            let nextFrame = self.trackVC.selectedFrameIndex + 1
            guard nextFrame < frameCount else {
                stopPlayback()
                return
            }
            trackVC.selectFrame(
                at: nextFrame,
                animated: false)
        }
    }
    
    private func stopPlayback() {
        guard isPlaying else { return }
        
        isPlaying = false
        toolbarVC.setPlayButtonPlaying(false)
        
        playbackTimer?.invalidate()
        playbackTimer = nil
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
    
    func onSelectPlay() {
        if !isPlaying {
            startPlayback()
        } else {
            stopPlayback()
        }
    }
    
    func onSelectFirstFrame() {
        trackVC.selectFrame(
            at: 0,
            animated: false)
    }
    
    func onSelectLastFrame() {
        trackVC.selectFrame(
            at: frameCount - 1,
            animated: false)
    }
    
    func onSelectPreviousFrame() {
        trackVC.selectFrame(
            at: trackVC.selectedFrameIndex - 1,
            animated: false)
    }
    
    func onSelectNextFrame() {
        trackVC.selectFrame(
            at: trackVC.selectedFrameIndex + 1,
            animated: false)
    }
    
    func onSelectToggleExpanded() {
        collapsibleBarVC.toggleExpanded()
    }
    
}

extension EditorTimelineVC: TimelineTrackVCDelegate {
    
    func onUpdateSelectedFrame(_ vc: TimelineTrackVC) {
        toolbarVC.updateFrameLabel(
            index: vc.selectedFrameIndex,
            total: frameCount)
    }
    
}
