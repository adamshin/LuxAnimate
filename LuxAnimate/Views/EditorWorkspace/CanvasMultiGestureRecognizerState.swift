//
//  CanvasMultiGestureRecognizerState.swift
//

import UIKit

private let translationDistanceThreshold: Scalar = 100
private let scaleDistanceThreshold: Scalar = 100
private let rotationDistanceThreshold: Scalar = 100
private let rotationAngleThreshold: Scalar = .pi / 4

protocol CanvasMultiGestureRecognizerStateDelegate: AnyObject {
    
    var view: UIView? { get }
    var numberOfTouches: Int { get }
    
    func setState(_ newState: CanvasMultiGestureRecognizerState)
    
    func onGestureBegan()
    func onGestureEnded()
    func onGestureFailed()
    
    func onBeginPan()
    func onUpdatePan(
        initialAnchorLocation: Vector,
        translation: Vector?,
        rotation: Scalar?,
        scale: Scalar?)
    func onEndPan()
    
}

protocol CanvasMultiGestureRecognizerState: AnyObject {
    
    var delegate: CanvasMultiGestureRecognizerStateDelegate? { get set }
    
    func onStateBegin()
    func onStateEnd()
    
    func touchesBegan(touches: Set<UITouch>, event: UIEvent)
    func touchesMoved(touches: Set<UITouch>, event: UIEvent)
    func touchesEnded(touches: Set<UITouch>, event: UIEvent)
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent)
    
}

extension CanvasMultiGestureRecognizerState {
    
    func onStateBegin() { }
    func onStateEnd() { }
    
    func touchesBegan(touches: Set<UITouch>, event: UIEvent) { }
    func touchesMoved(touches: Set<UITouch>, event: UIEvent) { }
    func touchesEnded(touches: Set<UITouch>, event: UIEvent) { }
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent) { }

}

// MARK: - Waiting

class CanvasMultiGestureRecognizerWaitingState: CanvasMultiGestureRecognizerState {
    
    weak var delegate: CanvasMultiGestureRecognizerStateDelegate?
    
    var activeTouches: [UITouch] = []
    
    func touchesBegan(
        touches: Set<UITouch>, event: UIEvent
    ) {
        if touches.contains(where: { $0.type != .direct }) {
            delegate?.setState(
                CanvasMultiGestureRecognizerInvalidState())
        }
        
        for touch in touches {
            activeTouches.append(touch)
            
            if activeTouches.count >= 2 {
                let touch1 = activeTouches[0]
                let touch2 = activeTouches[1]
                
                delegate?.setState(
                    CanvasMultiGestureRecognizerActiveState(
                        touch1: touch1,
                        touch2: touch2))
            }
        }
    }
    
    func touchesEnded(touches: Set<UITouch>, event: UIEvent) {
        delegate?.setState(CanvasMultiGestureRecognizerWaitingState())
    }
    
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent) {
        delegate?.setState(CanvasMultiGestureRecognizerWaitingState())
    }
    
}

// MARK: - Invalid

class CanvasMultiGestureRecognizerInvalidState: CanvasMultiGestureRecognizerState {
    
    weak var delegate: CanvasMultiGestureRecognizerStateDelegate?
    
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
                CanvasMultiGestureRecognizerWaitingState())
        }
    }
    
}

// MARK: - Active

class CanvasMultiGestureRecognizerActiveState: CanvasMultiGestureRecognizerState {
        
    struct TranslationState {
        var offset: Vector
    }
    struct RotationState {
        var offset: Scalar
    }
    struct ScaleState {
        var baseDistance: Scalar
    }
    
    weak var delegate: CanvasMultiGestureRecognizerStateDelegate?
    
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
        
        let initialAnchorLocation =
            (touch1InitialPos + touch2InitialPos) / 2
        let currentAnchorLocation =
            (touch1CurrentPos + touch2CurrentPos) / 2
        
        let initialTouchDifference = touch2InitialPos - touch1InitialPos
        let currentTouchDifference = touch2CurrentPos - touch1CurrentPos
        
        let initialTouchDistance = initialTouchDifference.length()
        let currentTouchDistance = currentTouchDifference.length()
        
        let translation: Vector?
        var rotation: Scalar?
        var scale: Scalar?
        
        // Translation
        let translationRaw = currentAnchorLocation - initialAnchorLocation
        
        if translationState == nil {
//            print("Translation raw: \(translationRaw.length())")
            if translationRaw.length() > translationDistanceThreshold {
//                print("Translation triggered")
                let offset =
                    translationRaw.inverse.normalized() *
                    translationDistanceThreshold
                
                translationState = TranslationState(offset: offset)
                beginGestureIfNecessary()
            }
        }
        
        if let translationState {
            translation = translationRaw + translationState.offset
//            print("Translation: \(translation!.length())")
        } else {
            translation = nil
        }
        
        // Rotation. TODO: Fix math here
        let rotationAngleRaw = initialTouchDifference
            .angle(with: currentTouchDifference)
        
        if rotationState == nil {
//            print("Rotation raw: \(rotationAngleRaw * .degreesPerRadian)")
            let distanceAngleThreshold =
                rotationDistanceThreshold /
                currentTouchDistance
            
            let currentAngleThreshold = min(
                rotationAngleThreshold,
                distanceAngleThreshold)
            
//            print("Threshold: \(currentAngleThreshold * .degreesPerRadian)")
            
            if abs(rotationAngleRaw) > currentAngleThreshold {
//                print("Rotation triggered")
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
//            print("Rotation: \(rotation! * .degreesPerRadian)")
        } else {
            rotation = nil
        }
        
        // Scale
        let scaleDistanceRaw = currentTouchDistance - initialTouchDistance
        
        if scaleState == nil {
//            print("Current distance: \(currentTouchDistance)")
//            print("Distance diff: \(scaleDistanceRaw)")
            if abs(scaleDistanceRaw) > scaleDistanceThreshold {
                let offset = if scaleDistanceRaw > 0 {
                    -scaleDistanceThreshold
                } else {
                    scaleDistanceThreshold
                }
                let baseDistance = initialTouchDistance - offset
                
//                print("Scale triggered. Base distance: \(baseDistance)")
                
                scaleState = ScaleState(baseDistance: baseDistance)
                beginGestureIfNecessary()
            }
        }
        
        if let scaleState {
            scale = currentTouchDistance / scaleState.baseDistance
//            print("Scale: \(scale!)")
        } else {
            scale = nil
        }
        
        // Finalize
        if hasGestureBegun {
            delegate?.onUpdatePan(
                initialAnchorLocation: initialAnchorLocation,
                translation: translation,
                rotation: rotation,
                scale: scale)
        }
    }
    
    func touchesEnded(touches: Set<UITouch>, event: UIEvent) {
        delegate?.onGestureEnded()
        delegate?.onEndPan()
        
        delegate?.setState(
            CanvasMultiGestureRecognizerWaitingState())
    }
    
    func touchesCancelled(touches: Set<UITouch>, event: UIEvent) {
        touchesEnded(touches: touches, event: event)
    }
    
    private func beginGestureIfNecessary() {
        if !hasGestureBegun {
            delegate?.onGestureBegan()
            delegate?.onBeginPan()
            hasGestureBegun = true
        }
    }
    
}

// MARK: - Geometry

private extension Vector2 {
    init(_ p: CGPoint) { self.init(x: p.x, y: p.y) }
}

private extension CGPoint {
    init(_ v: Vector2) { self.init(x: v.x, y: v.y) }
}
