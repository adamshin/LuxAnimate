//
//  EditorCollapsibleContentSwipeGestureRecognizer.swift
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

private let moveThreshold: CGFloat = 25
private let flickVelocityThreshold: CGFloat = 500

@MainActor
protocol EditorCollapsibleContentSwipeGestureRecognizerDelegate: AnyObject {
    func onSwipe(up: Bool)
}

class EditorCollapsibleContentSwipeGestureRecognizer: UIGestureRecognizer {
    
    weak var gestureDelegate: EditorCollapsibleContentSwipeGestureRecognizerDelegate?
    
    struct TrackedTouch {
        var touch: UITouch
        var initialPos: CGPoint
        var lastPos: CGPoint
        var lastTimestamp: TimeInterval
        var velocityY: CGFloat
    }
    
    var trackedTouch: TrackedTouch?
    
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent
    ) {
        if trackedTouch == nil, let touch = touches.first {
            trackedTouch = TrackedTouch(
                touch: touch,
                initialPos: touch.location(in: view),
                lastPos: touch.location(in: view),
                lastTimestamp: touch.timestamp,
                velocityY: 0)
        }
        for touch in touches {
            if touch != trackedTouch?.touch {
                ignore(touch, for: event)
            }
        }
    }
    
    override func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent
    ) {
        guard let trackedTouch else { return }
        
        let currentPos = trackedTouch.touch.location(in: view)
        let currentTimestamp = trackedTouch.touch.timestamp
        
        let lastPos = trackedTouch.lastPos
        let lastTimestamp = trackedTouch.lastTimestamp
        
        let dTime = currentTimestamp - lastTimestamp
        let dPosY = currentPos.y - lastPos.y
        let velocityY = dPosY / dTime
        
        self.trackedTouch?.lastPos = currentPos
        self.trackedTouch?.lastTimestamp = currentTimestamp
        self.trackedTouch?.velocityY = velocityY
        
        let translationX = currentPos.x - trackedTouch.initialPos.x
        let translationY = currentPos.y - trackedTouch.initialPos.y
        
        if abs(translationX) >= moveThreshold || 
            abs(translationY) >= moveThreshold
        {
            if abs(translationX) > abs(translationY) {
                state = .failed
            } else {
                state = .ended
                gestureDelegate?.onSwipe(up: translationY < 0)
            }
        }
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent
    ) {
        guard let trackedTouch else {
            state = .failed
            return
        }
        
        let velocityY = trackedTouch.velocityY
        
        if abs(velocityY) >= flickVelocityThreshold {
            state = .ended
            gestureDelegate?.onSwipe(up: velocityY < 0)
        } else {
            state = .failed
        }
    }
    
    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent
    ) {
        state = .failed
    }
    
    override func reset() {
        super.reset()
        trackedTouch = nil
    }
    
}
