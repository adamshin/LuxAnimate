//
//  EditorMenuDismissGestureRecognizer.swift
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

private let maxDragDistance: CGFloat = 10

@MainActor
protocol EditorMenuDismissGestureRecognizerDelegate: AnyObject {
    
    func onDismiss(_ gesture: EditorMenuDismissGestureRecognizer)
    
}

class EditorMenuDismissGestureRecognizer: UIGestureRecognizer {
    
    weak var gestureDelegate: EditorMenuDismissGestureRecognizerDelegate?
    
    private var touchInitialLocations: [UITouch: CGPoint] = [:]
    private var hasFired = false
    
    override func touchesBegan(
        _ touches: Set<UITouch>, with event: UIEvent
    ) {
        state = .began
        
        for touch in touches {
            let loc = touch.location(in: view)
            touchInitialLocations[touch] = loc
        }
    }
    
    override func touchesMoved(
        _ touches: Set<UITouch>, with event: UIEvent
    ) {
        for touch in touches {
            guard let initialLoc = touchInitialLocations[touch]
            else { continue }
                    
            let loc = touch.location(in: view)
            let dx = abs(loc.x - initialLoc.x)
            let dy = abs(loc.y - initialLoc.y)
            
            if max(dx, dy) >= maxDragDistance {
                state = .failed
                fire()
            }
        }
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>, with event: UIEvent
    ) {
        state = .failed
        fire()
    }
    
    override func touchesCancelled(
        _ touches: Set<UITouch>, with event: UIEvent
    ) {
        state = .failed
        fire()
    }
    
    override func reset() {
        super.reset()
        fire()
    }
    
    private func fire() {
        guard !hasFired else { return }
        hasFired = true
        gestureDelegate?.onDismiss(self)
    }
    
}
