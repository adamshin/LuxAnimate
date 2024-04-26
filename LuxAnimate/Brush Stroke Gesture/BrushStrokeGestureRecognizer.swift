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

protocol BrushStrokeGestureRecognizerGestureDelegate: AnyObject {
    
    func onBeginBrushStroke()
    
    func onUpdateBrushStroke(
        _ stroke: BrushStrokeGestureRecognizer.Stroke)
    
    func onEndBrushStroke()
    
}

class BrushStrokeGestureRecognizer: UIGestureRecognizer {
    
    weak var gestureDelegate: BrushStrokeGestureRecognizerGestureDelegate?
    
    private var internalState: BrushStrokeGestureRecognizerInternalState?
    
    init() {
        super.init(target: nil, action: nil)
        
        setinternalState(BrushStrokeGestureRecognizerWaitingState())
    }
    
    // MARK: - Gesture Lifecycle
    
    override func touchesBegan(
        _ touches: Set<UITouch>, with event: UIEvent
    ) {
        internalState?.touchesBegan(
            touches: touches, event: event)
    }
    
    override func touchesMoved(
        _ touches: Set<UITouch>, with event: UIEvent
    ) { 
        internalState?.touchesMoved(
            touches: touches, event: event)
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>, with event: UIEvent
    ) {
        internalState?.touchesEnded(
            touches: touches, event: event)
    }
    
    override func touchesCancelled(
        _ touches: Set<UITouch>, with event: UIEvent
    ) {
        internalState?.touchesCancelled(
            touches: touches, event: event)
    }
    
    override func touchesEstimatedPropertiesUpdated(
        _ touches: Set<UITouch>
    ) {
        internalState?.touchesEstimatedPropertiesUpdated(
            touches: touches)
    }
    
    override func reset() {
        super.reset()
        setinternalState(BrushStrokeGestureRecognizerWaitingState())
    }
    
    // MARK: - State
    
    private func setinternalState(_ newState: BrushStrokeGestureRecognizerInternalState) {
        internalState?.onStateEnd()
        internalState = newState
        
        newState.delegate = self
        newState.onStateBegin()
    }
    
}

// MARK: - State Delegate

extension BrushStrokeGestureRecognizer: BrushStrokeGestureRecognizerInternalStateDelegate {
    
    func setState(_ newState: BrushStrokeGestureRecognizerInternalState) {
        setinternalState(newState)
    }
    
    func setGestureRecognizerState(_ newState: UIGestureRecognizer.State) {
        state = newState
    }
    
    func onBeginBrushStroke() {
        gestureDelegate?.onBeginBrushStroke()
    }
    
    func onUpdateBrushStroke(_ stroke: BrushStrokeGestureRecognizer.Stroke) {
        gestureDelegate?.onUpdateBrushStroke(stroke)
    }
    
    func onEndBrushStroke() {
        gestureDelegate?.onEndBrushStroke()
    }
    
}
