//
//  StrokeGestureRecognizer.swift
//

import UIKit

protocol StrokeGestureRecognizerStrokeDelegate: AnyObject {
    
    func onBeginStroke()
    
    func onUpdateStroke(
        _ stroke: StrokeGestureRecognizer.Stroke)
    
    func onEndStroke()
    
}

class StrokeGestureRecognizer: UIGestureRecognizer {
    
    weak var strokeDelegate: StrokeGestureRecognizerStrokeDelegate?
    
    var strokeState: StrokeGestureRecognizerState?
    
    init() {
        super.init(target: nil, action: nil)
        
        setStrokeState(StrokeGestureRecognizerWaitingState())
    }
    
    // MARK: - Gesture Lifecycle
    
    override func touchesBegan(
        _ touches: Set<UITouch>, with event: UIEvent
    ) {
        strokeState?.touchesBegan(
            touches: touches, event: event)
    }
    
    override func touchesMoved(
        _ touches: Set<UITouch>, with event: UIEvent
    ) { 
        strokeState?.touchesMoved(
            touches: touches, event: event)
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>, with event: UIEvent
    ) {
        strokeState?.touchesEnded(
            touches: touches, event: event)
    }
    
    override func touchesCancelled(
        _ touches: Set<UITouch>, with event: UIEvent
    ) {
        strokeState?.touchesCancelled(
            touches: touches, event: event)
    }
    
    override func touchesEstimatedPropertiesUpdated(
        _ touches: Set<UITouch>
    ) {
        strokeState?.touchesEstimatedPropertiesUpdated(
            touches: touches)
    }
    
    // MARK: - State
    
    private func setStrokeState(_ newState: StrokeGestureRecognizerState) {
        strokeState?.onStateEnd()
        
        strokeState = newState
        
        newState.delegate = self
        newState.onStateBegin()
    }
    
}

// MARK: - State Delegate

extension StrokeGestureRecognizer: StrokeGestureRecognizerStateDelegate {
    
    func setState(_ newState: StrokeGestureRecognizerState) {
        setStrokeState(newState)
    }
    
    func onGestureBegan() { state = .began }
    func onGestureEnded() { state = .ended }
    func onGestureFailed() { state = .failed }
    
    func onBeginStroke() {
        strokeDelegate?.onBeginStroke()
    }
    func onUpdateStroke(_ stroke: StrokeGestureRecognizer.Stroke) {
        strokeDelegate?.onUpdateStroke(stroke)
    }
    func onEndStroke() {
        strokeDelegate?.onEndStroke()
    }
    
}
