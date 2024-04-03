//
//  CanvasMultiGestureRecognizerState.swift
//

import UIKit

private let translationDistanceThreshold: Scalar = 10

private let rotationDistanceThreshold: Scalar = 40
private let rotationMaxAngleThreshold: Scalar = .pi / 8

private let scaleDistanceThreshold: Scalar = 20

protocol CanvasMultiGestureRecognizerInternalStateDelegate: AnyObject {
    
    var view: UIView? { get }
    var numberOfTouches: Int { get }
    
    func setState(_ newState: CanvasMultiGestureRecognizerInternalState)
    func setGestureRecognizerState(_ newState: UIGestureRecognizer.State)
    
    func onBeginGesture()
    
    func onUpdateGesture(
        initialAnchorLocation: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar)
    
    func onEndGesture()
    
}

protocol CanvasMultiGestureRecognizerInternalState: AnyObject {
    
    var delegate: CanvasMultiGestureRecognizerInternalStateDelegate? { get set }
    
    func onBegin()
    func onEnd()
    
    func touchesBegan(touches: Set<UITouch>, event: UIEvent)
    func touchesMoved(touches: Set<UITouch>, event: UIEvent)
    func touchesEnded(touches: Set<UITouch>, event: UIEvent)
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent)
    
}

extension CanvasMultiGestureRecognizerInternalState {
    
    func onBegin() { }
    func onEnd() { }
    
    func touchesBegan(touches: Set<UITouch>, event: UIEvent) { }
    func touchesMoved(touches: Set<UITouch>, event: UIEvent) { }
    func touchesEnded(touches: Set<UITouch>, event: UIEvent) { }
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent) { }

}

// MARK: - Waiting

class CanvasMultiGestureRecognizerWaitingState: CanvasMultiGestureRecognizerInternalState {
    
    weak var delegate: CanvasMultiGestureRecognizerInternalStateDelegate?
    
    var currentTouches: [UITouch] = []
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        if touches.contains(where: { $0.type != .direct }) {
            delegate?.setGestureRecognizerState(.failed)
        }
        
        currentTouches += touches
        
        if currentTouches.count >= 2 {
            let touch1 = currentTouches[0]
            let touch2 = currentTouches[1]
            
            let touch1Pos = Vector(touch1.location(in: delegate?.view))
            let touch2Pos = Vector(touch2.location(in: delegate?.view))
            let difference = touch2Pos - touch1Pos
            
            guard difference.length() > 10 else {
                delegate?.setGestureRecognizerState(.failed)
                return
            }
            
            delegate?.setState(
                CanvasMultiGestureRecognizerActiveState(
                    touch1: touch1,
                    touch2: touch2))
        }
    }
    
    func touchesEnded(touches: Set<UITouch>, event: UIEvent) {
        delegate?.setGestureRecognizerState(.failed)
    }
    
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent) {
        delegate?.setGestureRecognizerState(.failed)
    }
    
}

// MARK: - Active

class CanvasMultiGestureRecognizerActiveState: CanvasMultiGestureRecognizerInternalState {
        
    struct TranslationState {
        var offset: Vector
    }
    struct RotationState {
        var offset: Scalar
    }
    struct ScaleState {
        var baseDistance: Scalar
    }
    
    weak var delegate: CanvasMultiGestureRecognizerInternalStateDelegate?
    
    private let touch1: UITouch
    private let touch2: UITouch
    
    private let touch1InitialPos: Vector
    private let touch2InitialPos: Vector
    
    private var translationState: TranslationState?
    private var rotationState: RotationState?
    private var scaleState: ScaleState?
    
    private var hasGestureBegun = false
    
    init(touch1: UITouch, touch2: UITouch) {
        self.touch1 = touch1
        self.touch2 = touch2
        
        touch1InitialPos = Vector(touch1.location(in: delegate?.view))
        touch2InitialPos = Vector(touch2.location(in: delegate?.view))
    }
    
    func touchesMoved(touches: Set<UITouch>, event: UIEvent) {
        let touch1CurrentPos = Vector(touch1.location(in: delegate?.view))
        let touch2CurrentPos = Vector(touch2.location(in: delegate?.view))
        
        let initialAnchorPos =
            (touch1InitialPos + touch2InitialPos) / 2
        let currentAnchorPos =
            (touch1CurrentPos + touch2CurrentPos) / 2
        
        let initialTouchDifference = touch2InitialPos - touch1InitialPos
        let currentTouchDifference = touch2CurrentPos - touch1CurrentPos
        
        let initialTouchDistance = initialTouchDifference.length()
        let currentTouchDistance = currentTouchDifference.length()
        
        // Output values
        let translation: Vector
        var rotation: Scalar
        var scale: Scalar
        
        // Translation
        let translationRaw = currentAnchorPos - initialAnchorPos
        
        if translationState == nil {
            if translationRaw.length() > translationDistanceThreshold {
                let offset =
                    translationRaw.inverse.normalized() *
                    translationDistanceThreshold
                
                translationState = TranslationState(offset: offset)
                beginGestureIfNecessary()
            }
        }
        
        if let translationState {
            translation = translationRaw + translationState.offset
        } else {
            translation = .zero
        }
        
        // Rotation
        let rotationAngleRaw = currentTouchDifference
            .angle(with: initialTouchDifference)
        
//        print(String(format: "Angle: %0.2f", rotationAngleRaw * .degreesPerRadian))
        
        if rotationState == nil {
            let distanceAngleThreshold =
                rotationDistanceThreshold /
                currentTouchDistance
            
            let currentAngleThreshold = min(
                rotationMaxAngleThreshold,
                distanceAngleThreshold)
            
            if abs(rotationAngleRaw) > currentAngleThreshold {
                let offset = if rotationAngleRaw > 0 {
                    -currentAngleThreshold
                } else {
                    currentAngleThreshold
                }
                rotationState = RotationState(offset: offset)
                beginGestureIfNecessary()
            }
        }
        
        if let rotationState {
            rotation = rotationAngleRaw + rotationState.offset
        } else {
            rotation = 0
        }
        
        // Scale
        let scaleDistanceRaw = currentTouchDistance - initialTouchDistance
        
        if scaleState == nil {
            if abs(scaleDistanceRaw) > scaleDistanceThreshold {
                let offset = if scaleDistanceRaw > 0 {
                    scaleDistanceThreshold
                } else {
                    -scaleDistanceThreshold
                }
                let baseDistance = max(initialTouchDistance + offset, 10)
                
                scaleState = ScaleState(baseDistance: baseDistance)
                beginGestureIfNecessary()
            }
        }
        
        if let scaleState {
            scale = currentTouchDistance / scaleState.baseDistance
        } else {
            scale = 1
        }
        
        // Finalize
        if hasGestureBegun {
            delegate?.onUpdateGesture(
                initialAnchorLocation: initialAnchorPos,
                translation: translation,
                rotation: rotation,
                scale: scale)
        }
    }
    
    func touchesEnded(touches: Set<UITouch>, event: UIEvent) {
        if touches.contains(touch1) || touches.contains(touch2) {
            delegate?.onEndGesture()
            delegate?.setGestureRecognizerState(.ended)
        }
    }
    
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent) {
        touchesEnded(touches: touches, event: event)
    }
    
    private func beginGestureIfNecessary() {
        if !hasGestureBegun {
            hasGestureBegun = true
            
            delegate?.onBeginGesture()
            delegate?.setGestureRecognizerState(.began)
        }
    }
    
}
