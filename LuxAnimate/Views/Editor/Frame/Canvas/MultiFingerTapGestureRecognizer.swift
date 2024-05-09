//
//  MultiFingerTapGestureRecognizer.swift
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

private let tapTimeWindow: TimeInterval = 0.2
private let maxMovement: CGFloat = 20

class MultiFingerTapGestureRecognizer: UIGestureRecognizer {
    
    struct TrackedTouch {
        let touch: UITouch
        let timestamp: TimeInterval
        let initialPos: CGPoint
    }
    
    private let touchCount: Int
    
    private var trackedTouches: [TrackedTouch] = []
    
    init(touchCount: Int) {
        self.touchCount = touchCount
        super.init(target: nil, action: nil)
    }
    
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent
    ) {
        for touch in touches {
            guard touch.type == .direct else {
                ignore(touch, for: event)
                continue
            }
            trackedTouches.append(TrackedTouch(
                touch: touch,
                timestamp: touch.timestamp,
                initialPos: touch.location(in: view)))
        }
    }
    
    override func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent
    ) {
        for trackedTouch in trackedTouches {
            let currentPos = trackedTouch.touch.location(in: view)
            let dist = currentPos.distance(to: trackedTouch.initialPos)
            
            if dist > maxMovement {
                state = .failed
                return
            }
        }
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent
    ) {
        guard trackedTouches.count == touchCount,
            let firstTouch = trackedTouches.first,
            let lastTouch = trackedTouches.last
        else {
            state = .failed
            return
        }
        
        let timeDifference = 
            lastTouch.timestamp - firstTouch.timestamp
        
        guard timeDifference <= tapTimeWindow else {
            state = .failed
            return
        }
        
        state = .ended
    }
    
    override func reset() {
        super.reset()
        trackedTouches = []
    }
    
}
