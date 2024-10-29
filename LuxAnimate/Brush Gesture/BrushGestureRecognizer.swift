//
//  BrushGestureRecognizer.swift
//

import UIKit

extension BrushGestureRecognizer {
    
    struct Config {
        static let pencilOnly = false
        static let usePredictedTouches = true
        
        static let fingerActivationDelay: TimeInterval = 0.25
        static let fingerActivationDistance: CGFloat = 20
        static let fingerSecondTouchCancellationThreshold: TimeInterval = 0.25
        
        static let strokeFinalizationDelay: TimeInterval = 0.1
        
        static let gapFillTimeOffset: TimeInterval = 1/120
    }
    
}

// MARK: - BrushGestureRecognizer Gesture Delegate

extension BrushGestureRecognizer {
    
    @MainActor
    protocol GestureDelegate: AnyObject {
        
        func onBeginStroke(
            _ g: BrushGestureRecognizer,
            quickTap: Bool)
        
        func onUpdateStroke(
            _ g: BrushGestureRecognizer,
            addedSamples: [Sample],
            predictedSamples: [Sample])
        
        func onUpdateStroke(
            _ g: BrushGestureRecognizer,
            sampleUpdates: [SampleUpdate])
        
        func onEndStroke(
            _ g: BrushGestureRecognizer)
        
        func onCancelStroke(
            _ g: BrushGestureRecognizer)
        
    }
    
}

// MARK: - BrushGestureRecognizer

@MainActor
class BrushGestureRecognizer: UIGestureRecognizer {
    
    weak var gestureDelegate: GestureDelegate?
    
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

// MARK: - Delegates

extension BrushGestureRecognizer:
    BrushGestureRecognizerInternalStateDelegate {
    
    func view(
        _ s: any BrushGestureRecognizerInternalState
    ) -> UIView? {
        view
    }
    
    func numberOfTouches(
        _ s: any BrushGestureRecognizerInternalState
    ) -> Int {
        numberOfTouches
    }
    
    func setInternalState(
        _ s: any BrushGestureRecognizerInternalState,
        _ newState: BrushGestureRecognizerInternalState
    ) {
        setInternalState(newState)
    }
    
    func setGestureRecognizerState(
        _ s: any BrushGestureRecognizerInternalState,
        _ newState: UIGestureRecognizer.State
    ) {
        state = newState
    }
    
    func onBeginStroke(
        _ s: any BrushGestureRecognizerInternalState,
        quickTap: Bool
    ) {
        gestureDelegate?.onBeginStroke(
            self,
            quickTap: quickTap)
    }
    
    func onUpdateStroke(
        _ s: BrushGestureRecognizerInternalState,
        addedSamples: [Sample],
        predictedSamples: [Sample]
    ) {
        gestureDelegate?.onUpdateStroke(
            self,
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    func onUpdateStroke(
        _ s: BrushGestureRecognizerInternalState,
        sampleUpdates: [SampleUpdate]
    ) {
        gestureDelegate?.onUpdateStroke(
            self,
            sampleUpdates: sampleUpdates)
    }
    
    func onEndStroke(
        _ s: any BrushGestureRecognizerInternalState
    ) {
        gestureDelegate?.onEndStroke(self)
    }
    
    func onCancelStroke(
        _ s: any BrushGestureRecognizerInternalState
    ) {
        gestureDelegate?.onCancelStroke(self)
    }
    
}
