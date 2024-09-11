//
//  CanvasMultiGestureRecognizer.swift
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

// MARK: - CanvasMultiGestureRecognizerDelegate

@MainActor
protocol CanvasMultiGestureRecognizerGestureDelegate: AnyObject {
    
    func onBeginGesture()
    
    func onUpdateGesture(
        initialAnchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar)
    
    func onEndGesture(
        finalAnchorPosition: Vector,
        pinchFlickIn: Bool)
    
}

// MARK: - CanvasMultiGestureRecognizer

class CanvasMultiGestureRecognizer: UIGestureRecognizer {
    
    weak var gestureDelegate: CanvasMultiGestureRecognizerGestureDelegate?
    
    private var internalState: CanvasMultiGestureRecognizerInternalState?

    init() {
        super.init(target: nil, action: nil)
        
        setInternalState(CanvasMultiGestureRecognizerWaitingState())
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
    
    override func reset() {
        super.reset()
        setInternalState(CanvasMultiGestureRecognizerWaitingState())
    }
    
    // MARK: - State
    
    private func setInternalState(_ newState: CanvasMultiGestureRecognizerInternalState) {
        internalState?.onEnd()
        internalState = newState
        
        newState.delegate = self
        newState.onBegin()
    }
    
}

// MARK: - Gesture State Delegate

extension CanvasMultiGestureRecognizer: CanvasMultiGestureRecognizerInternalStateDelegate {
    
    func setState(_ newState: CanvasMultiGestureRecognizerInternalState) {
        setInternalState(newState)
    }
    
    func setGestureRecognizerState(_ newState: UIGestureRecognizer.State) {
        state = newState
    }
    
    func onBeginGesture() {
        gestureDelegate?.onBeginGesture()
    }
    
    func onUpdateGesture(
        initialAnchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        gestureDelegate?.onUpdateGesture(
            initialAnchorPosition: initialAnchorPosition,
            translation: translation,
            rotation: rotation,
            scale: scale)
    }
    
    func onEndGesture(
        finalAnchorPosition: Vector,
        pinchFlickIn: Bool
    ) {
        gestureDelegate?.onEndGesture(
            finalAnchorPosition: finalAnchorPosition,
            pinchFlickIn: pinchFlickIn)
    }
    
}
