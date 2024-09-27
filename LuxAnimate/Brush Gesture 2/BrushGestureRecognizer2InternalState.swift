//
//  BrushGestureRecognizer2InternalState.swift
//

import UIKit

@MainActor
protocol BrushGestureRecognizer2InternalStateDelegate:
    AnyObject {
    
    func view(
        _ s: BrushGestureRecognizer2InternalState
    ) -> UIView?
    
    func numberOfTouches(
        _ s: BrushGestureRecognizer2InternalState
    ) -> Int
    
    func setInternalState(
        _ s: BrushGestureRecognizer2InternalState,
        _ newState: BrushGestureRecognizer2InternalState)
    
    func setGestureRecognizerState(
        _ s: BrushGestureRecognizer2InternalState,
        _ newState: UIGestureRecognizer.State)
    
    func onBeginStroke(
        _ s: BrushGestureRecognizer2InternalState,
        quickTap: Bool)
    
    func onUpdateStroke(
        _ s: BrushGestureRecognizer2InternalState,
        addedSamples: [BrushGestureRecognizer2.Sample],
        predictedSamples: [BrushGestureRecognizer2.Sample])
    
    func onUpdateStroke(
        _ s: BrushGestureRecognizer2InternalState,
        sampleUpdates: [BrushGestureRecognizer2.SampleUpdate])
    
    func onEndStroke(
        _ s: BrushGestureRecognizer2InternalState)
    
    func onCancelStroke(
        _ s: BrushGestureRecognizer2InternalState)
    
}

@MainActor
protocol BrushGestureRecognizer2InternalState:
    AnyObject {
    
    var delegate:
        BrushGestureRecognizer2InternalStateDelegate?
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

extension BrushGestureRecognizer2InternalState {
    
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

class BrushGestureRecognizer2WaitingState:
    BrushGestureRecognizer2InternalState {
    
    weak var delegate:
        BrushGestureRecognizer2InternalStateDelegate?
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard let touch = touches.first,
            touches.count == 1
        else {
            delegate?.setInternalState(self,
                BrushGestureRecognizer2InvalidState())
            return
        }
        
        if BrushStrokeGestureConfig.pencilOnly,
            touch.type != .pencil
        {
            delegate?.setInternalState(self,
                BrushGestureRecognizer2InvalidState())
            return
        }
        
        let view = delegate?.view(self)
        let startTime = touch.timestamp
        
        let (samples, _) = BrushGestureHelper
            .extractSamples(
                touch: touch,
                event: event,
                startTime: startTime,
                view: view)
        
        delegate?.setInternalState(self,
            BrushGestureRecognizer2PreActiveState(
                touch: touch,
                startTime: startTime,
                queuedSamples: samples))
    }
    
}

// MARK: - Pre Active

@MainActor
class BrushGestureRecognizer2PreActiveState:
    BrushGestureRecognizer2InternalState {
    
    weak var delegate:
        BrushGestureRecognizer2InternalStateDelegate?
    
    private let touch: UITouch
    private let startTime: TimeInterval
    
    private var queuedSamples: [BrushGestureRecognizer2.Sample]
    private var predictedSamples: [BrushGestureRecognizer2.Sample]
    
    private var activationTimer: Timer?
    
    init(
        touch: UITouch,
        startTime: TimeInterval,
        queuedSamples: [BrushGestureRecognizer2.Sample]
    ) {
        self.touch = touch
        self.startTime = startTime
        self.queuedSamples = queuedSamples
        self.predictedSamples = []
        
        self.activationTimer = nil
    }
    
    func onStateBegin() {
        if touch.type == .direct {
            let timeInterval = BrushGestureRecognizer2
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
            BrushGestureRecognizer2WaitingState())
    }
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        delegate?.setInternalState(self,
            BrushGestureRecognizer2InvalidState())
    }
    
    func touchesMoved(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(touch) else { return }
        
        let view = delegate?.view(self)
        
        let (samples, predictedSamples) = BrushGestureHelper
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
            self, quickTap: true)
        
        delegate?.onUpdateStroke(
            self,
            addedSamples: queuedSamples,
            predictedSamples: [])
        
        delegate?.setInternalState(self,
            BrushGestureRecognizer2PostActiveState())
    }
    
    func touchesCancelled(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(touch) else { return }
        
        delegate?.setGestureRecognizerState(self, .failed)
    }
    
    func touchesEstimatedPropertiesUpdated(
        touches: Set<UITouch>
    ) {
        let view = delegate?.view(self)
        
        let sampleUpdates = BrushGestureHelper
            .extractSampleUpdates(
                touches: touches,
                view: view)
        
        for sampleUpdate in sampleUpdates {
            if let index = queuedSamples.firstIndex(where: {
                $0.updateID == sampleUpdate.updateID
            }) {
                let sample = queuedSamples[index]
                    .applying(sampleUpdate: sampleUpdate)
                
                queuedSamples[index] = sample
            }
        }
    }
    
    private func checkActivationThreshold() {
        guard let s1 = queuedSamples.first,
            let s2 = queuedSamples.last
        else { return }
        
        let d = s1.position.distance(to: s2.position)
        
        if d >= BrushStrokeGestureConfig.fingerActivationDistance {
            activateStroke()
        }
    }
    
    private func activateStroke() {
        delegate?.onBeginStroke(
            self, quickTap: false)
        
        delegate?.onUpdateStroke(
            self,
            addedSamples: queuedSamples,
            predictedSamples: predictedSamples)
        
        delegate?.setGestureRecognizerState(self, .began)
        
        delegate?.setInternalState(self,
            BrushGestureRecognizer2ActiveState(
                touch: touch,
                startTime: startTime))
    }
    
}

// MARK: - Active

class BrushGestureRecognizer2ActiveState:
    BrushGestureRecognizer2InternalState {
    
    weak var delegate:
        BrushGestureRecognizer2InternalStateDelegate?
    
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
            BrushGestureRecognizer2WaitingState())
    }
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        if touch.type == .direct {
            let cancellationThreshold = startTime +
                BrushGestureRecognizer2.Config
                    .fingerSecondTouchCancellationThreshold
            
            if touches.contains(
                where: { $0.timestamp < cancellationThreshold })
            {
                delegate?.onCancelStroke(self)
                
                delegate?.setInternalState(self,
                    BrushGestureRecognizer2WaitingState())
                
                delegate?.setGestureRecognizerState(self, .failed)
            }
        }
    }
    
    func touchesMoved(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(touch) else { return }
        
        let view = delegate?.view(self)
        
        let (samples, predictedSamples) = BrushGestureHelper
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
            BrushGestureRecognizer2PostActiveState())
    }
    
    func touchesCancelled(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(touch) else { return }
        
        delegate?.onCancelStroke(self)
        
        delegate?.setInternalState(self,
            BrushGestureRecognizer2WaitingState())
        
        delegate?.setGestureRecognizerState(self, .failed)
    }
    
    func touchesEstimatedPropertiesUpdated(
        touches: Set<UITouch>
    ) {
        let view = delegate?.view(self)
        
        let sampleUpdates = BrushGestureHelper
            .extractSampleUpdates(
                touches: touches,
                view: view)
        
        delegate?.onUpdateStroke(
            self, sampleUpdates: sampleUpdates)
    }
    
}

// MARK: - Post Active

class BrushGestureRecognizer2PostActiveState:
    BrushGestureRecognizer2InternalState {
    
    weak var delegate:
        BrushGestureRecognizer2InternalStateDelegate?
    
    private var finalizationTimer: Timer?
    
    func onStateBegin() {
        delegate?.setGestureRecognizerState(self, .ended)
        
        let timerInterval = BrushStrokeGestureConfig
            .estimateFinalizationDelay
        
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
        let proxyState = BrushGestureRecognizer2WaitingState()
        proxyState.delegate = delegate
        proxyState.touchesBegan(touches: touches, event: event)
    }
    
    func touchesEstimatedPropertiesUpdated(
        touches: Set<UITouch>
    ) {
        let view = delegate?.view(self)
        
        let sampleUpdates = BrushGestureHelper
            .extractSampleUpdates(
                touches: touches,
                view: view)
        
        delegate?.onUpdateStroke(
            self, sampleUpdates: sampleUpdates)
    }
    
    private func finalizeStroke() {
        delegate?.setInternalState(self,
            BrushGestureRecognizer2WaitingState())
    }
    
}

// MARK: - Invalid

class BrushGestureRecognizer2InvalidState:
    BrushGestureRecognizer2InternalState {
    
    weak var delegate:
        BrushGestureRecognizer2InternalStateDelegate?
    
    func resetGesture() {
        delegate?.setInternalState(self,
            BrushGestureRecognizer2WaitingState())
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
