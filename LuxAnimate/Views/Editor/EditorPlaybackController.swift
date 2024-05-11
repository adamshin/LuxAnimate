//
//  EditorPlaybackController.swift
//

import Foundation
import QuartzCore

protocol EditorPlaybackControllerDelegate: AnyObject {
    
    func onBeginPlayback(_ c: EditorPlaybackController)
    
    func onUpdatePlayback(
        _ c: EditorPlaybackController,
        frameIndex: Int)
    
    func onEndPlayback(_ c: EditorPlaybackController)
    
}

class EditorPlaybackController {
    
    weak var delegate: EditorPlaybackControllerDelegate?
    
    private var frameCount: Int = 0
    private var framesPerSecond: Int = 1
    
    private var playbackStartTime: CFTimeInterval?
    private var playbackStartFrameIndex: Int?
    
    private let displayLink = WrappedDisplayLink()
    
    init() {
        displayLink.setCallback { [weak self] in
            self?.onFrame()
        }
    }
    
    private func onFrame() {
        guard let playbackStartTime, 
            let playbackStartFrameIndex
        else { return }
        
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - playbackStartTime
        
        let elapsedFrameCount =
            Int(elapsedTime * Double(framesPerSecond))
        
        let currentFrameIndex =
            playbackStartFrameIndex + elapsedFrameCount
        
        if currentFrameIndex >= frameCount {
            self.playbackStartTime = nil
            self.playbackStartFrameIndex = nil
            
            delegate?.onEndPlayback(self)
            
        } else {
            delegate?.onUpdatePlayback(self,
                frameIndex: currentFrameIndex)
        }
    }
    
    func setModel(_ model: EditorTimelineModel) {
        frameCount = model.frames.count
        framesPerSecond = model.framesPerSecond
    }
    
    func startPlayback(frameIndex: Int) {
        guard frameIndex >= 0, frameIndex < frameCount
        else { return }
        
        let adjustedFrameIndex: Int
        if frameIndex == frameCount - 1 {
            adjustedFrameIndex = 0
        } else {
            adjustedFrameIndex = frameIndex
        }
        
        playbackStartTime = CACurrentMediaTime()
        playbackStartFrameIndex = adjustedFrameIndex
        
        delegate?.onBeginPlayback(self)
        delegate?.onUpdatePlayback(self,
            frameIndex: adjustedFrameIndex)
    }
    
    func stopPlayback() {
        playbackStartTime = nil
        playbackStartFrameIndex = nil
        
        delegate?.onEndPlayback(self)
    }
    
    var isPlaying: Bool {
        playbackStartTime != nil
    }
    
}
