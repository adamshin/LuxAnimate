//
//  BrushStrokeGestureRecognizerInternalState.swift
//

import UIKit

protocol BrushStrokeGestureRecognizerInternalStateDelegate: AnyObject {
    
    var view: UIView? { get }
    var numberOfTouches: Int { get }
    
    func setState(_ newState: BrushStrokeGestureRecognizerInternalState)
    
    func setGestureRecognizerState(_ newState: UIGestureRecognizer.State)
    
    func onBeginBrushStroke()
    func onUpdateBrushStroke(_ stroke: BrushStrokeGestureRecognizer.Stroke)
    func onEndBrushStroke()
    
}

protocol BrushStrokeGestureRecognizerInternalState: AnyObject {
    
    var delegate: BrushStrokeGestureRecognizerInternalStateDelegate? { get set }
    
    func onStateBegin()
    func onStateEnd()
    
    func touchesBegan(touches: Set<UITouch>, event: UIEvent)
    func touchesMoved(touches: Set<UITouch>, event: UIEvent)
    func touchesEnded(touches: Set<UITouch>, event: UIEvent)
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent)
    
    func touchesEstimatedPropertiesUpdated(touches: Set<UITouch>)
    
}

extension BrushStrokeGestureRecognizerInternalState {
    
    func onStateBegin() { }
    func onStateEnd() { }
    
    func touchesBegan(touches: Set<UITouch>, event: UIEvent) { }
    func touchesMoved(touches: Set<UITouch>, event: UIEvent) { }
    func touchesEnded(touches: Set<UITouch>, event: UIEvent) { }
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent) { }
    
    func touchesEstimatedPropertiesUpdated(touches: Set<UITouch>) { }

}

// MARK: - Waiting

class BrushStrokeGestureRecognizerWaitingState: BrushStrokeGestureRecognizerInternalState {
    
    weak var delegate: BrushStrokeGestureRecognizerInternalStateDelegate?
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) { 
        guard let touch = touches.first, touches.count == 1 else {
            delegate?.setState(
                BrushStrokeGestureRecognizerInvalidState())
            return
        }
        
        if BrushStrokeGestureConfig.pencilOnly, touch.type != .pencil {
            delegate?.setState(
                BrushStrokeGestureRecognizerInvalidState())
            return
        }
        
        var stroke = BrushStrokeGestureRecognizer.Stroke(touch: touch)
        
        stroke.update(event: event, view: delegate?.view)
        
        delegate?.setState(
            BrushStrokeGestureRecognizerPreActiveState(
                stroke: stroke))
    }
    
}

// MARK: - Pre Active

class BrushStrokeGestureRecognizerPreActiveState: BrushStrokeGestureRecognizerInternalState {
    
    weak var delegate: BrushStrokeGestureRecognizerInternalStateDelegate?
    
    private var stroke: BrushStrokeGestureRecognizer.Stroke
    private var activationTimer: Timer?
    
    init(stroke: BrushStrokeGestureRecognizer.Stroke) {
        self.stroke = stroke
        self.activationTimer = nil
    }
    
    deinit {
        activationTimer?.invalidate()
    }
    
    func onStateBegin() {
        if stroke.touch.type == .direct {
            activationTimer = Timer.scheduledTimer(
                withTimeInterval: BrushStrokeGestureConfig.fingerActivationDelay,
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
            BrushStrokeGestureRecognizerInvalidState())
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
        
        delegate?.onBeginBrushStroke()
        delegate?.onUpdateBrushStroke(stroke)
        
        delegate?.setGestureRecognizerState(.ended)
        
        delegate?.setState(
            BrushStrokeGestureRecognizerPostActiveState(
                stroke: stroke))
    }
    
    func touchesCancelled(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(stroke.touch) else { return }
        
        delegate?.setGestureRecognizerState(.failed)
        
        delegate?.setState(
            BrushStrokeGestureRecognizerWaitingState())
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
        
        if d >= BrushStrokeGestureConfig.fingerActivationDistance {
            activateStroke()
        }
    }
    
    private func activateStroke() {
        delegate?.onBeginBrushStroke()
        delegate?.onUpdateBrushStroke(stroke)
        
        delegate?.setGestureRecognizerState(.began)
        
        delegate?.setState(
            BrushStrokeGestureRecognizerActiveState(
                stroke: stroke))
    }
    
}

// MARK: - Active

class BrushStrokeGestureRecognizerActiveState: BrushStrokeGestureRecognizerInternalState {
    
    weak var delegate: BrushStrokeGestureRecognizerInternalStateDelegate?
    
    private var stroke: BrushStrokeGestureRecognizer.Stroke
    
    init(stroke: BrushStrokeGestureRecognizer.Stroke) {
        self.stroke = stroke
    }
    
    func touchesMoved(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(stroke.touch) else { return }
        
        stroke.update(event: event, view: delegate?.view)
        delegate?.onUpdateBrushStroke(stroke)
    }
    
    func touchesEnded(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(stroke.touch) else { return }
        
        stroke.hasTouchEnded = true
        stroke.predictedSamples = []
        
        delegate?.onUpdateBrushStroke(stroke)
        
        delegate?.setGestureRecognizerState(.ended)
        
        delegate?.setState(
            BrushStrokeGestureRecognizerPostActiveState(
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
        delegate?.onUpdateBrushStroke(stroke)
    }
    
}

// MARK: - Post Active

class BrushStrokeGestureRecognizerPostActiveState: BrushStrokeGestureRecognizerInternalState {
    
    weak var delegate: BrushStrokeGestureRecognizerInternalStateDelegate?
    
    private var stroke: BrushStrokeGestureRecognizer.Stroke
    private var finalizationTimer: Timer?
    
    init(stroke: BrushStrokeGestureRecognizer.Stroke) {
        self.stroke = stroke
    }
    
    deinit {
        finalizationTimer?.invalidate()
    }
    
    func onStateBegin() {
        finalizationTimer = Timer.scheduledTimer(
            withTimeInterval: BrushStrokeGestureConfig.estimateFinalizationDelay,
            repeats: false)
        { [weak self] _ in
            self?.delegate?.setState(
                BrushStrokeGestureRecognizerWaitingState())
        }
    }
    
    func onStateEnd() {
        delegate?.onEndBrushStroke()
    }
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        let proxyState = BrushStrokeGestureRecognizerWaitingState()
        proxyState.delegate = delegate
        
        proxyState.touchesBegan(touches: touches, event: event)
    }
    
    func touchesEstimatedPropertiesUpdated(
        touches: Set<UITouch>
    ) {
        stroke.updateEstimated(touches: touches, view: delegate?.view)
        delegate?.onUpdateBrushStroke(stroke)
    }
    
}

// MARK: - Invalid

class BrushStrokeGestureRecognizerInvalidState: BrushStrokeGestureRecognizerInternalState {
    
    weak var delegate: BrushStrokeGestureRecognizerInternalStateDelegate?
    
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
            delegate?.setGestureRecognizerState(.failed)
            
            delegate?.setState(
                BrushStrokeGestureRecognizerWaitingState())
        }
    }
    
}
