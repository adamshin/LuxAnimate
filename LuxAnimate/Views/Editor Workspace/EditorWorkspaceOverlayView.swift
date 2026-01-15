//
//  EditorWorkspaceOverlayView.swift
//

import UIKit
import Geometry

extension EditorWorkspaceOverlayView {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onBeginWorkspaceTransformGesture(
            _ v: EditorWorkspaceOverlayView)
        
        func onUpdateWorkspaceTransformGesture(
            _ v: EditorWorkspaceOverlayView,
            initialAnchorPosition: Vector,
            translation: Vector,
            rotation: Double,
            scale: Double)
        
        func onEndWorkspaceTransformGesture(
            _ v: EditorWorkspaceOverlayView,
            finalAnchorPosition: Vector,
            pinchFlickIn: Bool)
        
        func onSelectUndo(_ v: EditorWorkspaceOverlayView)
        func onSelectRedo(_ v: EditorWorkspaceOverlayView)
        
    }
    
}

class EditorWorkspaceOverlayView: UIView {
    
    weak var delegate: Delegate?
    
    private let multiGesture = CanvasMultiGestureRecognizer()
    private let panGesture = UIPanGestureRecognizer()
    
    private let undoGesture = MultiFingerTapGestureRecognizer(touchCount: 2)
    private let redoGesture = MultiFingerTapGestureRecognizer(touchCount: 3)
    
    private var overlayGestureRecognizers: [UIGestureRecognizer] = []
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        addGestureRecognizer(multiGesture)
        multiGesture.gestureDelegate = self
        
        addGestureRecognizer(panGesture)
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(onPan))
        panGesture.isEnabled = false
        
        addGestureRecognizer(undoGesture)
        addGestureRecognizer(redoGesture)
        undoGesture.addTarget(self, action: #selector(onUndoGesture))
        redoGesture.addTarget(self, action: #selector(onRedoGesture))
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Gesture Handlers
    
    @objc private func onUndoGesture() {
        delegate?.onSelectUndo(self)
    }
    
    @objc private func onRedoGesture() {
        delegate?.onSelectRedo(self)
    }
    
    @objc private func onPan() {
        switch panGesture.state {
        case .began:
            delegate?.onBeginWorkspaceTransformGesture(self)
            
        case .changed:
            let translation = Vector(
                panGesture.translation(in: self))
            
            delegate?.onUpdateWorkspaceTransformGesture(
                self,
                initialAnchorPosition: .zero,
                translation: translation,
                rotation: 0,
                scale: 1)
            
        default:
            delegate?.onEndWorkspaceTransformGesture(
                self,
                finalAnchorPosition: .zero,
                pinchFlickIn: false)
        }
    }
    
    // MARK: - Interface
    
    func addOverlayGestureRecognizer(_ g: UIGestureRecognizer) {
        addGestureRecognizer(g)
        overlayGestureRecognizers.append(g)
    }
    
    func removeAllOverlayGestureRecognizers() {
        for g in overlayGestureRecognizers {
            removeGestureRecognizer(g)
        }
        overlayGestureRecognizers = []
    }
    
}

// MARK: - Delegates

extension EditorWorkspaceOverlayView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        if gestureRecognizer == panGesture {
            return touch.type == .direct
        }
        return true
    }
    
}

extension EditorWorkspaceOverlayView: CanvasMultiGestureRecognizerGestureDelegate {
    
    func onBeginGesture() {
        delegate?.onBeginWorkspaceTransformGesture(self)
    }
    
    func onUpdateGesture(
        initialAnchorPosition: Vector,
        translation: Vector,
        rotation: Double,
        scale: Double
    ) {
        delegate?.onUpdateWorkspaceTransformGesture(
            self,
            initialAnchorPosition: initialAnchorPosition,
            translation: translation,
            rotation: rotation,
            scale: scale)
    }
    
    func onEndGesture(
        finalAnchorPosition: Vector,
        pinchFlickIn: Bool
    ) {
        delegate?.onEndWorkspaceTransformGesture(
            self,
            finalAnchorPosition: finalAnchorPosition,
            pinchFlickIn: pinchFlickIn)
    }
    
}
