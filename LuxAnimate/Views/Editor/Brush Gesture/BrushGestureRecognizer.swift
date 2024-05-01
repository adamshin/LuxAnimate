//
//  BrushGestureRecognizer.swift
//

import UIKit

struct BrushStrokeGestureConfig {
    
    static let pencilOnly = false
    static let usePredictedTouches = true
    
    static let fingerActivationDelay: TimeInterval = 0.25
    static let fingerActivationDistance: CGFloat = 10
    
    static let estimateFinalizationDelay: TimeInterval = 0.1
    
}

protocol BrushGestureRecognizerGestureDelegate: AnyObject {
    
    func onBeginBrushStroke()
    
    func onUpdateBrushStroke(
        _ stroke: BrushGestureRecognizer.Stroke)
    
    func onEndBrushStroke()
    
}

class BrushGestureRecognizer: UIGestureRecognizer {
    
    weak var gestureDelegate: BrushGestureRecognizerGestureDelegate?
    
    private var internalState: BrushGestureRecognizerInternalState?
    
    init() {
        super.init(target: nil, action: nil)
        
        setInternalState(BrushGestureRecognizerWaitingState())
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
        internalState?.resetGesture()
    }
    
    // MARK: - State
    
    private func setInternalState(
        _ newState: BrushGestureRecognizerInternalState
    ) {
        internalState?.onStateEnd()
        internalState = newState
        
        newState.delegate = self
        newState.onStateBegin()
    }
    
}

// MARK: - State Delegate

extension BrushGestureRecognizer: BrushGestureRecognizerInternalStateDelegate {
    
    func setState(_ newState: BrushGestureRecognizerInternalState) {
        setInternalState(newState)
    }
    
    func setGestureRecognizerState(_ newState: UIGestureRecognizer.State) {
        state = newState
    }
    
    func onBeginBrushStroke() {
        gestureDelegate?.onBeginBrushStroke()
    }
    
    func onUpdateBrushStroke(_ stroke: BrushGestureRecognizer.Stroke) {
        gestureDelegate?.onUpdateBrushStroke(stroke)
    }
    
    func onEndBrushStroke() {
        gestureDelegate?.onEndBrushStroke()
    }
    
}
