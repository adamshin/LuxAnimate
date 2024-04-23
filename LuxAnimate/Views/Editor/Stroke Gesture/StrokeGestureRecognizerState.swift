//
//  StrokeGestureRecognizerState.swift
//

import UIKit

protocol StrokeGestureRecognizerStateDelegate: AnyObject {
    
    var view: UIView? { get }
    var numberOfTouches: Int { get }
    
    func setState(_ newState: StrokeGestureRecognizerState)
    
    func onGestureBegan()
    func onGestureEnded()
    func onGestureFailed()
    
    func onBeginStroke()
    func onUpdateStroke(_ stroke: StrokeGestureRecognizer.Stroke)
    func onEndStroke()
    
}

protocol StrokeGestureRecognizerState: AnyObject {
    
    var delegate: StrokeGestureRecognizerStateDelegate? { get set }
    
    func onStateBegin()
    func onStateEnd()
    
    func touchesBegan(touches: Set<UITouch>, event: UIEvent)
    func touchesMoved(touches: Set<UITouch>, event: UIEvent)
    func touchesEnded(touches: Set<UITouch>, event: UIEvent)
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent)
    
    func touchesEstimatedPropertiesUpdated(touches: Set<UITouch>)
    
}

extension StrokeGestureRecognizerState {
    
    func onStateBegin() { }
    func onStateEnd() { }
    
    func touchesBegan(touches: Set<UITouch>, event: UIEvent) { }
    func touchesMoved(touches: Set<UITouch>, event: UIEvent) { }
    func touchesEnded(touches: Set<UITouch>, event: UIEvent) { }
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent) { }
    
    func touchesEstimatedPropertiesUpdated(touches: Set<UITouch>) { }

}

// MARK: - Waiting

class StrokeGestureRecognizerWaitingState: StrokeGestureRecognizerState {
    
    weak var delegate: StrokeGestureRecognizerStateDelegate?
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard let touch = touches.first, touches.count == 1 else {
            delegate?.setState(
                StrokeGestureRecognizerInvalidState())
            return
        }
        
        if AppConfig.strokeGesturePencilOnly, touch.type != .pencil {
            delegate?.setState(
                StrokeGestureRecognizerInvalidState())
            return
        }
        
        var stroke = StrokeGestureRecognizer.Stroke(touch: touch)
        
        stroke.update(event: event, view: delegate?.view)
        
        delegate?.setState(
            StrokeGestureRecognizerPreActiveState(
                stroke: stroke))
    }
    
}

// MARK: - Pre Active

class StrokeGestureRecognizerPreActiveState: StrokeGestureRecognizerState {
    
    weak var delegate: StrokeGestureRecognizerStateDelegate?
    
    private var stroke: StrokeGestureRecognizer.Stroke
    private var activationTimer: Timer?
    
    init(stroke: StrokeGestureRecognizer.Stroke) {
        self.stroke = stroke
        self.activationTimer = nil
    }
    
    deinit {
        activationTimer?.invalidate()
    }
    
    func onStateBegin() {
        if stroke.touch.type == .direct {
            activationTimer = Timer.scheduledTimer(
                withTimeInterval: AppConfig.strokeGestureFingerActivationDelay,
                repeats: false)
            { [weak self] _ in
                self?.activateStroke()
            }
        } else {
            activateStroke()
        }
    }
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        delegate?.setState(
            StrokeGestureRecognizerInvalidState())
    }
    
    func touchesMoved(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(stroke.touch) else { return }
        
        stroke.update(event: event, view: delegate?.view)
        checkActivationThreshold()
    }
    
    func touchesEnded(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(stroke.touch) else { return }
        
        stroke.hasTouchEnded = true
        stroke.predictedSamples = []
        
        delegate?.onBeginStroke()
        delegate?.onUpdateStroke(stroke)
        
        delegate?.onGestureEnded()
        
        delegate?.setState(
            StrokeGestureRecognizerPostActiveState(
                stroke: stroke))
    }
    
    func touchesCancelled(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(stroke.touch) else { return }
        
        delegate?.onGestureFailed()
        
        delegate?.setState(
            StrokeGestureRecognizerWaitingState())
    }
    
    func touchesEstimatedPropertiesUpdated(
        touches: Set<UITouch>
    ) {
        stroke.updateEstimated(touches: touches, view: delegate?.view)
    }
    
    private func checkActivationThreshold() {
        guard let s1 = stroke.samples.first,
            let s2 = stroke.samples.last
        else { return }
        
        let d = s1.position.distance(to: s2.position)
        
        if d >= AppConfig.strokeGestureFingerActivationDistance {
            activateStroke()
        }
    }
    
    private func activateStroke() {
        delegate?.onBeginStroke()
        delegate?.onUpdateStroke(stroke)
        
        delegate?.onGestureBegan()
        
        delegate?.setState(
            StrokeGestureRecognizerActiveState(
                stroke: stroke))
    }
    
}

// MARK: - Active

class StrokeGestureRecognizerActiveState: StrokeGestureRecognizerState {
    
    weak var delegate: StrokeGestureRecognizerStateDelegate?
    
    private var stroke: StrokeGestureRecognizer.Stroke
    
    init(stroke: StrokeGestureRecognizer.Stroke) {
        self.stroke = stroke
    }
    
    func touchesMoved(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(stroke.touch) else { return }
        
        stroke.update(event: event, view: delegate?.view)
        delegate?.onUpdateStroke(stroke)
    }
    
    func touchesEnded(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(stroke.touch) else { return }
        
        stroke.hasTouchEnded = true
        stroke.predictedSamples = []
        
        delegate?.onUpdateStroke(stroke)
        
        delegate?.onGestureEnded()
        
        delegate?.setState(
            StrokeGestureRecognizerPostActiveState(
                stroke: stroke))
    }
    
    func touchesCancelled(
        touches: Set<UITouch>, event: UIEvent
    ) {
        touchesEnded(touches: touches, event: event)
    }
    
    func touchesEstimatedPropertiesUpdated(
        touches: Set<UITouch>
    ) {
        stroke.updateEstimated(touches: touches, view: delegate?.view)
        delegate?.onUpdateStroke(stroke)
    }
    
}

// MARK: - Post Active

class StrokeGestureRecognizerPostActiveState: StrokeGestureRecognizerState {
    
    weak var delegate: StrokeGestureRecognizerStateDelegate?
    
    private var stroke: StrokeGestureRecognizer.Stroke
    private var finalizationTimer: Timer?
    
    init(stroke: StrokeGestureRecognizer.Stroke) {
        self.stroke = stroke
    }
    
    deinit {
        finalizationTimer?.invalidate()
    }
    
    func onStateBegin() {
        finalizationTimer = Timer.scheduledTimer(
            withTimeInterval: AppConfig.strokeGestureEstimateFinalizationDelay,
            repeats: false)
        { [weak self] _ in
            self?.delegate?.setState(
                StrokeGestureRecognizerWaitingState())
        }
    }
    
    func onStateEnd() {
        delegate?.onEndStroke()
    }
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        let proxyState = StrokeGestureRecognizerWaitingState()
        proxyState.delegate = delegate
        
        proxyState.touchesBegan(touches: touches, event: event)
    }
    
    func touchesEstimatedPropertiesUpdated(
        touches: Set<UITouch>
    ) {
        stroke.updateEstimated(touches: touches, view: delegate?.view)
        delegate?.onUpdateStroke(stroke)
    }
    
}

// MARK: - Invalid

class StrokeGestureRecognizerInvalidState: StrokeGestureRecognizerState {
    
    weak var delegate: StrokeGestureRecognizerStateDelegate?
    
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
        let previousTouchCount = delegate?.numberOfTouches ?? 0
        let remainingTouchCount = previousTouchCount - touchCount
        
        if remainingTouchCount <= 0 {
            delegate?.onGestureFailed()
            
            delegate?.setState(
                StrokeGestureRecognizerWaitingState())
        }
    }
    
}
