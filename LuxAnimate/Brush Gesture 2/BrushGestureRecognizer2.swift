//
//  BrushGestureRecognizer2.swift
//

import UIKit

extension BrushGestureRecognizer2 {
    
    struct Config {
        static let pencilOnly = false
        static let usePredictedTouches = true
        
        static let fingerActivationDelay: TimeInterval = 0.25
        static let fingerActivationDistance: CGFloat = 20
        static let fingerSecondTouchCancellationThreshold: TimeInterval = 0.25
        
        static let strokeFinalizationDelay: TimeInterval = 0.1
    }
    
    @MainActor
    struct Sample {
        var timeOffset: TimeInterval
        var isPredicted: Bool
        var updateID: Int?
        
        var position: CGPoint
        
        var maximumPossibleForce: Double
        
        var force: Double
        var altitude: Double
        var azimuth: CGVector
        
        var isForceEstimated: Bool
        var isAltitudeEstimated: Bool
        var isAzimuthEstimated: Bool
        
        var hasEstimatedValues: Bool {
            isForceEstimated ||
            isAltitudeEstimated ||
            isAzimuthEstimated
        }
        
        func applying(
            sampleUpdate u: SampleUpdate
        ) -> Sample {
            var s = self
            s.force = u.force ?? s.force
            s.altitude = u.altitude ?? s.altitude
            s.azimuth = u.azimuth ?? s.azimuth
            return s
        }
    }
    
    struct SampleUpdate {
        var updateID: Int
        
        var force: Double?
        var altitude: Double?
        var azimuth: CGVector?
    }
    
}

// MARK: - BrushGestureRecognizer Gesture Delegate

extension BrushGestureRecognizer2 {
    
    @MainActor
    protocol GestureDelegate: AnyObject {
        
        func onBeginStroke(
            _ g: BrushGestureRecognizer2,
            quickTap: Bool)
        
        func onUpdateStroke(
            _ g: BrushGestureRecognizer2,
            addedSamples: [Sample],
            predictedSamples: [Sample])
        
        func onUpdateStroke(
            _ g: BrushGestureRecognizer2,
            sampleUpdates: [SampleUpdate])
        
        func onEndStroke(
            _ g: BrushGestureRecognizer2)
        
        func onCancelStroke(
            _ g: BrushGestureRecognizer2)
        
    }
    
}

// MARK: - BrushGestureRecognizer

@MainActor
class BrushGestureRecognizer2: UIGestureRecognizer {
    
    weak var gestureDelegate: GestureDelegate?
    
    private var internalState: BrushGestureRecognizer2InternalState?
    
    init() {
        super.init(target: nil, action: nil)
        
        setInternalState(BrushGestureRecognizer2WaitingState())
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
        _ newState: BrushGestureRecognizer2InternalState
    ) {
        internalState?.onStateEnd()
        internalState = newState
        
        newState.delegate = self
        newState.onStateBegin()
    }
    
}

// MARK: - Delegates

extension BrushGestureRecognizer2:
    BrushGestureRecognizer2InternalStateDelegate {
    
    func view(
        _ s: any BrushGestureRecognizer2InternalState
    ) -> UIView? {
        view
    }
    
    func numberOfTouches(
        _ s: any BrushGestureRecognizer2InternalState
    ) -> Int {
        numberOfTouches
    }
    
    func setInternalState(
        _ s: any BrushGestureRecognizer2InternalState,
        _ newState: BrushGestureRecognizer2InternalState
    ) {
        setInternalState(newState)
    }
    
    func setGestureRecognizerState(
        _ s: any BrushGestureRecognizer2InternalState,
        _ newState: UIGestureRecognizer.State
    ) {
        state = newState
    }
    
    func onBeginStroke(
        _ s: any BrushGestureRecognizer2InternalState,
        quickTap: Bool
    ) {
        gestureDelegate?.onBeginStroke(
            self, quickTap: quickTap)
    }
    
    func onUpdateStroke(
        _ s: BrushGestureRecognizer2InternalState,
        addedSamples: [Sample],
        predictedSamples: [Sample]
    ) {
        gestureDelegate?.onUpdateStroke(
            self,
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    func onUpdateStroke(
        _ s: BrushGestureRecognizer2InternalState,
        sampleUpdates: [SampleUpdate]
    ) {
        gestureDelegate?.onUpdateStroke(
            self,
            sampleUpdates: sampleUpdates)
    }
    
    func onEndStroke(
        _ s: any BrushGestureRecognizer2InternalState
    ) {
        gestureDelegate?.onEndStroke(self)
    }
    
    func onCancelStroke(
        _ s: any BrushGestureRecognizer2InternalState
    ) {
        gestureDelegate?.onCancelStroke(self)
    }
    
}

