//
//  CanvasMultiGestureRecognizer.swift
//

import UIKit

protocol CanvasMultiGestureRecognizerPanDelegate: AnyObject {
    
    func onBeginPan()
    
    func onUpdatePan(
        initialAnchorLocation: Vector,
        translation: Vector?,
        rotation: Scalar?,
        scale: Scalar?)
    
    func onEndPan()
    
}

class CanvasMultiGestureRecognizer: UIGestureRecognizer {
    
    weak var panDelegate: CanvasMultiGestureRecognizerPanDelegate?
    
    private var panState: CanvasMultiGestureRecognizerState?

    init() {
        super.init(target: nil, action: nil)
        
        setPanState(CanvasMultiGestureRecognizerWaitingState())
    }
    
    // MARK: - Gesture Lifecycle
    
    override func touchesBegan(
        _ touches: Set<UITouch>, with event: UIEvent
    ) {
        panState?.touchesBegan(
            touches: touches, event: event)
    }
    
    override func touchesMoved(
        _ touches: Set<UITouch>, with event: UIEvent
    ) { 
        panState?.touchesMoved(
            touches: touches, event: event)
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>, with event: UIEvent
    ) {
        panState?.touchesEnded(
            touches: touches, event: event)
    }
    
    override func touchesCancelled(
        _ touches: Set<UITouch>, with event: UIEvent
    ) {
        panState?.touchesCancelled(
            touches: touches, event: event)
    }
    
    // MARK: - State
    
    private func setPanState(_ newState: CanvasMultiGestureRecognizerState) {
        panState?.onStateEnd()
        
        panState = newState
        
        newState.delegate = self
        newState.onStateBegin()
    }
    
}

// MARK: - State Delegate

extension CanvasMultiGestureRecognizer: CanvasMultiGestureRecognizerStateDelegate {
    
    func setState(_ newState: CanvasMultiGestureRecognizerState) {
        setPanState(newState)
    }
    
    func onGestureBegan() { state = .began }
    func onGestureEnded() { state = .ended }
    func onGestureFailed() { state = .failed }
    
    func onBeginPan() {
        panDelegate?.onBeginPan()
    }
    
    func onUpdatePan(
        initialAnchorLocation: Vector,
        translation: Vector?,
        rotation: Scalar?,
        scale: Scalar?
    ) {
        panDelegate?.onUpdatePan(
            initialAnchorLocation: initialAnchorLocation,
            translation: translation,
            rotation: rotation,
            scale: scale)
    }
    
    func onEndPan() {
        panDelegate?.onEndPan()
    }
    
}
