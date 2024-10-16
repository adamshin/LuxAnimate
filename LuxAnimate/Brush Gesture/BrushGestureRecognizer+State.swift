//
//  BrushGestureRecognizer+State.swift
//

import UIKit

@MainActor
protocol BrushGestureRecognizerInternalStateDelegate:
    AnyObject {
    
    func view(
        _ s: BrushGestureRecognizerInternalState
    ) -> UIView?
    
    func numberOfTouches(
        _ s: BrushGestureRecognizerInternalState
    ) -> Int
    
    func setInternalState(
        _ s: BrushGestureRecognizerInternalState,
        _ newState: BrushGestureRecognizerInternalState)
    
    func setGestureRecognizerState(
        _ s: BrushGestureRecognizerInternalState,
        _ newState: UIGestureRecognizer.State)
    
    func onBeginStroke(
        _ s: BrushGestureRecognizerInternalState,
        quickTap: Bool)
    
    func onUpdateStroke(
        _ s: BrushGestureRecognizerInternalState,
        addedSamples: [BrushGestureRecognizer.Sample],
        predictedSamples: [BrushGestureRecognizer.Sample])
    
    func onUpdateStroke(
        _ s: BrushGestureRecognizerInternalState,
        sampleUpdates: [BrushGestureRecognizer.SampleUpdate])
    
    func onEndStroke(
        _ s: BrushGestureRecognizerInternalState)
    
    func onCancelStroke(
        _ s: BrushGestureRecognizerInternalState)
    
}

@MainActor
protocol BrushGestureRecognizerInternalState:
    AnyObject {
    
    var delegate:
        BrushGestureRecognizerInternalStateDelegate?
    { get set }
    
    func onStateBegin()
    func onStateEnd()
    func resetGesture()
    
    func touchesBegan(touches: Set<UITouch>, event: UIEvent)
    func touchesMoved(touches: Set<UITouch>, event: UIEvent)
    func touchesEnded(touches: Set<UITouch>, event: UIEvent)
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent)
    func touchesEstimatedPropertiesUpdated(touches: Set<UITouch>)
    
}

extension BrushGestureRecognizerInternalState {
    
    func onStateBegin() { }
    func onStateEnd() { }
    func resetGesture() { }
    
    func touchesBegan(touches: Set<UITouch>, event: UIEvent) { }
    func touchesMoved(touches: Set<UITouch>, event: UIEvent) { }
    func touchesEnded(touches: Set<UITouch>, event: UIEvent) { }
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent) { }
    func touchesEstimatedPropertiesUpdated(touches: Set<UITouch>) { }

}

// MARK: - Waiting

class BrushGestureRecognizerWaitingState:
    BrushGestureRecognizerInternalState {
    
    weak var delegate:
        BrushGestureRecognizerInternalStateDelegate?
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard let touch = touches.first,
            touches.count == 1
        else {
            delegate?.setInternalState(self,
                BrushGestureRecognizerInvalidState())
            return
        }
        
        if BrushGestureRecognizer.Config.pencilOnly,
            touch.type != .pencil
        {
            delegate?.setInternalState(self,
                BrushGestureRecognizerInvalidState())
            return
        }
        
        let view = delegate?.view(self)
        let startTime = touch.timestamp
        
        let (samples, _) = BrushGestureRecognizer
            .extractSamples(
                touch: touch,
                event: event,
                startTime: startTime,
                view: view)
        
        delegate?.setInternalState(self,
            BrushGestureRecognizerPreActiveState(
                touch: touch,
                startTime: startTime,
                queuedSamples: samples))
    }
    
}

// MARK: - Pre Active

@MainActor
class BrushGestureRecognizerPreActiveState:
    BrushGestureRecognizerInternalState {
    
    weak var delegate:
        BrushGestureRecognizerInternalStateDelegate?
    
    private let touch: UITouch
    private let startTime: TimeInterval
    
    private var queuedSamples: [BrushGestureRecognizer.Sample]
    private var predictedSamples: [BrushGestureRecognizer.Sample]
    
    private var activationTimer: Timer?
    
    init(
        touch: UITouch,
        startTime: TimeInterval,
        queuedSamples: [BrushGestureRecognizer.Sample]
    ) {
        self.touch = touch
        self.startTime = startTime
        self.queuedSamples = queuedSamples
        self.predictedSamples = []
        
        self.activationTimer = nil
    }
    
    func onStateBegin() {
        if touch.type == .direct {
            let timeInterval = BrushGestureRecognizer
                .Config.fingerActivationDelay
            
            activationTimer = Timer.scheduledTimer(
                withTimeInterval: timeInterval,
                repeats: false)
            { [weak self] _ in
                Task { @MainActor in
                    self?.activateStroke()
                }
            }
        } else {
            activateStroke()
        }
    }
    
    func onStateEnd() {
        activationTimer?.invalidate()
    }
    
    func resetGesture() {
        delegate?.setInternalState(self,
            BrushGestureRecognizerWaitingState())
    }
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        delegate?.setInternalState(self,
            BrushGestureRecognizerInvalidState())
    }
    
    func touchesMoved(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(touch) else { return }
        
        let view = delegate?.view(self)
        
        let (samples, predictedSamples) = BrushGestureRecognizer
            .extractSamples(
                touch: touch,
                event: event,
                startTime: startTime,
                view: view)
        
        self.queuedSamples += samples
        self.predictedSamples = predictedSamples
        
        checkActivationThreshold()
    }
    
    func touchesEnded(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(touch) else { return }
        
        delegate?.onBeginStroke(
            self,
            quickTap: true)
        
        delegate?.onUpdateStroke(
            self,
            addedSamples: queuedSamples,
            predictedSamples: [])
        
        delegate?.setInternalState(self,
            BrushGestureRecognizerPostActiveState())
    }
    
    func touchesCancelled(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(touch) else { return }
        
        delegate?.setGestureRecognizerState(self, .failed)
    }
    
    private func checkActivationThreshold() {
        guard let s1 = queuedSamples.first,
            let s2 = queuedSamples.last
        else { return }
        
        let d = s1.position.distance(to: s2.position)
        
        if d >= BrushGestureRecognizer.Config
            .fingerActivationDistance
        {
            activateStroke()
        }
    }
    
    private func activateStroke() {
        delegate?.onBeginStroke(
            self,
            quickTap: false)
        
        delegate?.onUpdateStroke(
            self,
            addedSamples: queuedSamples,
            predictedSamples: predictedSamples)
        
        delegate?.setGestureRecognizerState(self, .began)
        
        delegate?.setInternalState(self,
            BrushGestureRecognizerActiveState(
                touch: touch,
                startTime: startTime))
    }
    
}

// MARK: - Active

class BrushGestureRecognizerActiveState:
    BrushGestureRecognizerInternalState {
    
    weak var delegate:
        BrushGestureRecognizerInternalStateDelegate?
    
    private let touch: UITouch
    private let startTime: TimeInterval
    
    init(
        touch: UITouch,
        startTime: TimeInterval
    ) {
        self.touch = touch
        self.startTime = startTime
    }
    
    func resetGesture() {
        delegate?.onEndStroke(self)
        delegate?.setInternalState(self,
            BrushGestureRecognizerWaitingState())
    }
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        if touch.type == .direct {
            let cancellationThreshold = startTime +
                BrushGestureRecognizer.Config
                    .fingerSecondTouchCancellationThreshold
            
            if touches.contains(
                where: { $0.timestamp < cancellationThreshold })
            {
                delegate?.onCancelStroke(self)
                
                delegate?.setInternalState(self,
                    BrushGestureRecognizerWaitingState())
                
                delegate?.setGestureRecognizerState(self, .failed)
            }
        }
    }
    
    func touchesMoved(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(touch) else { return }
        
        let view = delegate?.view(self)
        
        let (samples, predictedSamples) = BrushGestureRecognizer
            .extractSamples(
                touch: touch,
                event: event,
                startTime: startTime,
                view: view)
        
        delegate?.onUpdateStroke(
            self,
            addedSamples: samples,
            predictedSamples: predictedSamples)
    }
    
    func touchesEnded(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(touch) else { return }
        
        delegate?.onUpdateStroke(
            self,
            addedSamples: [],
            predictedSamples: [])
        
        delegate?.setInternalState(self,
            BrushGestureRecognizerPostActiveState())
    }
    
    func touchesCancelled(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(touch) else { return }
        
        delegate?.onCancelStroke(self)
        
        delegate?.setInternalState(self,
            BrushGestureRecognizerWaitingState())
        
        delegate?.setGestureRecognizerState(self, .failed)
    }
    
    func touchesEstimatedPropertiesUpdated(
        touches: Set<UITouch>
    ) {
        let view = delegate?.view(self)
        
        let sampleUpdates = BrushGestureRecognizer
            .extractSampleUpdates(
                touches: touches,
                view: view)
        
        delegate?.onUpdateStroke(
            self, sampleUpdates: sampleUpdates)
    }
    
}

// MARK: - Post Active

class BrushGestureRecognizerPostActiveState:
    BrushGestureRecognizerInternalState {
    
    weak var delegate:
        BrushGestureRecognizerInternalStateDelegate?
    
    private var finalizationTimer: Timer?
    
    func onStateBegin() {
        delegate?.setGestureRecognizerState(self, .ended)
        
        let timerInterval = BrushGestureRecognizer.Config
            .strokeFinalizationDelay
        
        finalizationTimer = Timer.scheduledTimer(
            withTimeInterval: timerInterval,
            repeats: false)
        { [weak self] _ in
            Task { @MainActor in
                self?.finalizeStroke()
            }
        }
    }
    
    func onStateEnd() {
        finalizationTimer?.invalidate()
        delegate?.onEndStroke(self)
    }
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        let proxyState = BrushGestureRecognizerWaitingState()
        proxyState.delegate = delegate
        proxyState.touchesBegan(touches: touches, event: event)
    }
    
    func touchesEstimatedPropertiesUpdated(
        touches: Set<UITouch>
    ) {
        let view = delegate?.view(self)
        
        let sampleUpdates = BrushGestureRecognizer
            .extractSampleUpdates(
                touches: touches,
                view: view)
        
        delegate?.onUpdateStroke(
            self, sampleUpdates: sampleUpdates)
    }
    
    private func finalizeStroke() {
        delegate?.setInternalState(self,
            BrushGestureRecognizerWaitingState())
    }
    
}

// MARK: - Invalid

class BrushGestureRecognizerInvalidState:
    BrushGestureRecognizerInternalState {
    
    weak var delegate:
        BrushGestureRecognizerInternalStateDelegate?
    
    func resetGesture() {
        delegate?.setInternalState(self,
            BrushGestureRecognizerWaitingState())
    }
    
    func touchesEnded(
        touches: Set<UITouch>, event: UIEvent
    ) {
        handleTouchEnd(touchCount: touches.count)
    }
    
    func touchesCancelled(
        touches: Set<UITouch>, event: UIEvent
    ) {
        handleTouchEnd(touchCount: touches.count)
    }
    
    private func handleTouchEnd(touchCount: Int) {
        let previousTouchCount = delegate?.numberOfTouches(self) ?? 0
        let remainingTouchCount = previousTouchCount - touchCount
        
        if remainingTouchCount <= 0 {
            delegate?.setGestureRecognizerState(self, .failed)
        }
    }
    
}
