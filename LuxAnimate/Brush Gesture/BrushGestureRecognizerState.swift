//
//  BrushGestureRecognizerInternalState.swift
//

import UIKit

@MainActor
protocol BrushGestureRecognizerInternalStateDelegate: AnyObject {
    
    var view: UIView? { get }
    var numberOfTouches: Int { get }
    
    func setState(_ newState: BrushGestureRecognizerInternalState)
    
    func setGestureRecognizerState(_ newState: UIGestureRecognizer.State)
    
    func onBeginBrushStroke(quickTap: Bool)
    func onUpdateBrushStroke(_ stroke: BrushGestureRecognizer.Stroke)
    func onEndBrushStroke()
    func onCancelBrushStroke()
    
}

@MainActor
protocol BrushGestureRecognizerInternalState: AnyObject {
    
    var delegate: BrushGestureRecognizerInternalStateDelegate? { get set }
    
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
    
    func touchesBegan(touches: Set<UITouch>, event: UIEvent) { }
    func touchesMoved(touches: Set<UITouch>, event: UIEvent) { }
    func touchesEnded(touches: Set<UITouch>, event: UIEvent) { }
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent) { }
    
    func touchesEstimatedPropertiesUpdated(touches: Set<UITouch>) { }

}

// MARK: - Waiting

class BrushGestureRecognizerWaitingState: BrushGestureRecognizerInternalState {
    
    weak var delegate: BrushGestureRecognizerInternalStateDelegate?
    
    func resetGesture() { }
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) { 
        guard let touch = touches.first, touches.count == 1 else {
            delegate?.setState(
                BrushGestureRecognizerInvalidState())
            return
        }
        
        if BrushStrokeGestureConfig.pencilOnly, touch.type != .pencil {
            delegate?.setState(
                BrushGestureRecognizerInvalidState())
            return
        }
        
        var stroke = BrushGestureRecognizer.Stroke(touch: touch)
        
        stroke.update(event: event, view: delegate?.view)
        
        delegate?.setState(
            BrushGestureRecognizerPreActiveState(
                stroke: stroke))
    }
    
}

// MARK: - Pre Active

@MainActor
class BrushGestureRecognizerPreActiveState: BrushGestureRecognizerInternalState {
    
    weak var delegate: BrushGestureRecognizerInternalStateDelegate?
    
    private var stroke: BrushGestureRecognizer.Stroke
    private var activationTimer: Timer?
    
    init(stroke: BrushGestureRecognizer.Stroke) {
        self.stroke = stroke
        self.activationTimer = nil
    }
    
    func onStateBegin() {
        if stroke.touch.type == .direct {
            activationTimer = Timer.scheduledTimer(
                withTimeInterval: BrushStrokeGestureConfig.fingerActivationDelay,
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
        delegate?.setState(
            BrushGestureRecognizerWaitingState())
    }
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        delegate?.setState(
            BrushGestureRecognizerInvalidState())
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
        
        delegate?.onBeginBrushStroke(quickTap: true)
        delegate?.onUpdateBrushStroke(stroke)
        
        delegate?.setState(
            BrushGestureRecognizerPostActiveState(
                stroke: stroke))
    }
    
    func touchesCancelled(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(stroke.touch) else { return }
        
        delegate?.setGestureRecognizerState(.failed)
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
        delegate?.onBeginBrushStroke(quickTap: false)
        delegate?.onUpdateBrushStroke(stroke)
        
        delegate?.setGestureRecognizerState(.began)
        
        delegate?.setState(
            BrushGestureRecognizerActiveState(
                stroke: stroke))
    }
    
}

// MARK: - Active

class BrushGestureRecognizerActiveState: BrushGestureRecognizerInternalState {
    
    weak var delegate: BrushGestureRecognizerInternalStateDelegate?
    
    private var stroke: BrushGestureRecognizer.Stroke
    
    init(stroke: BrushGestureRecognizer.Stroke) {
        self.stroke = stroke
    }
    
    func resetGesture() {
        delegate?.onEndBrushStroke()
        delegate?.setState(
            BrushGestureRecognizerWaitingState())
    }
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        if stroke.touch.type == .direct {
            let cancellationThreshold = stroke.startTimestamp +
                BrushStrokeGestureConfig.fingerSecondTouchCancellationThreshold
            
            if touches.contains(
                where: { $0.timestamp < cancellationThreshold })
            {
                delegate?.onCancelBrushStroke()
                delegate?.setState(BrushGestureRecognizerWaitingState())
                delegate?.setGestureRecognizerState(.failed)
            }
        }
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
        
        delegate?.setState(
            BrushGestureRecognizerPostActiveState(
                stroke: stroke))
    }
    
    func touchesCancelled(
        touches: Set<UITouch>, event: UIEvent
    ) {
        guard touches.contains(stroke.touch) else { return }
        
        delegate?.onCancelBrushStroke()
        delegate?.setState(BrushGestureRecognizerWaitingState())
        delegate?.setGestureRecognizerState(.failed)
    }
    
    func touchesEstimatedPropertiesUpdated(
        touches: Set<UITouch>
    ) {
        stroke.updateEstimated(touches: touches, view: delegate?.view)
        delegate?.onUpdateBrushStroke(stroke)
    }
    
}

// MARK: - Post Active

class BrushGestureRecognizerPostActiveState: BrushGestureRecognizerInternalState {
    
    weak var delegate: BrushGestureRecognizerInternalStateDelegate?
    
    private var stroke: BrushGestureRecognizer.Stroke
    private var finalizationTimer: Timer?
    
    init(stroke: BrushGestureRecognizer.Stroke) {
        self.stroke = stroke
    }
    
    func onStateBegin() {
        delegate?.setGestureRecognizerState(.ended)
        
        finalizationTimer = Timer.scheduledTimer(
            withTimeInterval: BrushStrokeGestureConfig.estimateFinalizationDelay,
            repeats: false)
        { [weak self] _ in
            Task { @MainActor in
                self?.delegate?.setState(
                    BrushGestureRecognizerWaitingState())
            }
        }
    }
    
    func onStateEnd() {
        finalizationTimer?.invalidate()
        
        delegate?.onEndBrushStroke()
    }
    
    func resetGesture() { }
    
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
        stroke.updateEstimated(touches: touches, view: delegate?.view)
        delegate?.onUpdateBrushStroke(stroke)
    }
    
}

// MARK: - Invalid

class BrushGestureRecognizerInvalidState: BrushGestureRecognizerInternalState {
    
    weak var delegate: BrushGestureRecognizerInternalStateDelegate?
    
    func resetGesture() {
        delegate?.setState(
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
        let previousTouchCount = delegate?.numberOfTouches ?? 0
        let remainingTouchCount = previousTouchCount - touchCount
        
        if remainingTouchCount <= 0 {
            delegate?.setGestureRecognizerState(.failed)
        }
    }
    
}
