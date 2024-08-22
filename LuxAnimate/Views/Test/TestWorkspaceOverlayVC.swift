//
//  TestWorkspaceOverlayVC.swift
//

import UIKit

protocol TestWorkspaceOverlayVCDelegate: AnyObject {
    
    func onBeginWorkspaceTransformGesture(
        _ vc: TestWorkspaceOverlayVC)
    
    func onUpdateWorkspaceTransformGesture(
        _ vc: TestWorkspaceOverlayVC,
        initialAnchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar)
    
    func onEndWorkspaceTransformGesture(
        _ vc: TestWorkspaceOverlayVC,
        finalAnchorPosition: Vector,
        pinchFlickIn: Bool)
    
    func onSelectUndo(_ vc: TestWorkspaceOverlayVC)
    func onSelectRedo(_ vc: TestWorkspaceOverlayVC)
    
    func onBeginBrushStroke(
        _ vc: TestWorkspaceOverlayVC,
        quickTap: Bool)
    
    func onUpdateBrushStroke(
        _ vc: TestWorkspaceOverlayVC,
        stroke: BrushGestureRecognizer.Stroke)
    
    func onEndBrushStroke(
        _ vc: TestWorkspaceOverlayVC)
    
    func onCancelBrushStroke(
        _ vc: TestWorkspaceOverlayVC)
    
}

class TestWorkspaceOverlayVC: UIViewController {
    
    weak var delegate: TestWorkspaceOverlayVCDelegate?
    
    private let multiGesture = CanvasMultiGestureRecognizer()
    private let panGesture = UIPanGestureRecognizer()
    
    private let undoGesture = MultiFingerTapGestureRecognizer(touchCount: 2)
    private let redoGesture = MultiFingerTapGestureRecognizer(touchCount: 3)
    
    private let brushGesture = BrushGestureRecognizer()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(multiGesture)
        multiGesture.gestureDelegate = self
        
        view.addGestureRecognizer(panGesture)
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(onPan))
        panGesture.isEnabled = false
        
        view.addGestureRecognizer(undoGesture)
        view.addGestureRecognizer(redoGesture)
        undoGesture.addTarget(self, action: #selector(onUndoGesture))
        redoGesture.addTarget(self, action: #selector(onRedoGesture))
        
        
        view.addGestureRecognizer(brushGesture)
        brushGesture.gestureDelegate = self
    }
    
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
                panGesture.translation(in: view))
            
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
    
}

// MARK: - Delegates

extension TestWorkspaceOverlayVC: UIGestureRecognizerDelegate {
    
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

extension TestWorkspaceOverlayVC: CanvasMultiGestureRecognizerGestureDelegate {
    
    func onBeginGesture() {
        delegate?.onBeginWorkspaceTransformGesture(self)
    }
    
    func onUpdateGesture(
        initialAnchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
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

extension TestWorkspaceOverlayVC: BrushGestureRecognizerGestureDelegate {
    
    func onBeginBrushStroke(quickTap: Bool) {
        delegate?.onBeginBrushStroke(
            self,
            quickTap: quickTap)
    }
    
    func onUpdateBrushStroke(
        _ stroke: BrushGestureRecognizer.Stroke
    ) {
        delegate?.onUpdateBrushStroke(
            self,
            stroke: stroke)
    }
    
    func onEndBrushStroke() {
        delegate?.onEndBrushStroke(self)
    }
    
    func onCancelBrushStroke() {
        delegate?.onCancelBrushStroke(self)
    }
    
}
