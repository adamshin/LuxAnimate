//
//  BrushStrokeGestureRecognizer.swift
//

import UIKit

struct BrushStrokeGestureConfig {
    
    static let pencilOnly = false
    static let usePredictedTouches = true
    
    static let fingerActivationDelay: TimeInterval = 0.25
    static let fingerActivationDistance: CGFloat = 10
    
    static let estimateFinalizationDelay: TimeInterval = 0.1
    
}

protocol BrushStrokeGestureRecognizerStrokeDelegate: AnyObject {
    
    func onBeginBrushStroke()
    
    func onUpdateBrushStroke(
        _ stroke: BrushStrokeGestureRecognizer.Stroke)
    
    func onEndBrushStroke()
    
}

class BrushStrokeGestureRecognizer: UIGestureRecognizer {
    
    weak var strokeDelegate: BrushStrokeGestureRecognizerStrokeDelegate?
    
    var strokeState: BrushStrokeGestureRecognizerState?
    
    init() {
        super.init(target: nil, action: nil)
        
        setStrokeState(BrushStrokeGestureRecognizerWaitingState())
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
    
    private func setStrokeState(_ newState: BrushStrokeGestureRecognizerState) {
        strokeState?.onStateEnd()
        
        strokeState = newState
        
        newState.delegate = self
        newState.onStateBegin()
    }
    
}

// MARK: - State Delegate

extension BrushStrokeGestureRecognizer: BrushStrokeGestureRecognizerStateDelegate {
    
    func setState(_ newState: BrushStrokeGestureRecognizerState) {
        setStrokeState(newState)
    }
    
    func onGestureBegan() { state = .began }
    func onGestureEnded() { state = .ended }
    func onGestureFailed() { state = .failed }
    
    func onBeginBrushStroke() {
        strokeDelegate?.onBeginBrushStroke()
    }
    func onUpdateBrushStroke(_ stroke: BrushStrokeGestureRecognizer.Stroke) {
        strokeDelegate?.onUpdateBrushStroke(stroke)
    }
    func onEndBrushStroke() {
        strokeDelegate?.onEndBrushStroke()
    }
    
}
