//
//  TestWorkspaceOverlayVC.swift
//

import UIKit

protocol TestWorkspaceOverlayVCDelegate: AnyObject {
    
    func onBeginWorkspaceTransformGesture(
        _ vc: TestWorkspaceOverlayVC)
    
    func onUpdateWorkspaceTransformGesture(
        _ vc: TestWorkspaceOverlayVC,
        anchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar)
    
    func onEndWorkspaceTransformGesture(
        _ vc: TestWorkspaceOverlayVC,
        pinchFlickIn: Bool)
    
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
        
        view.addGestureRecognizer(brushGesture)
        brushGesture.gestureDelegate = self
    }
    
    // MARK: - Pan Gesture
    
    @objc private func onPan() {
        switch panGesture.state {
        case .began:
            delegate?.onBeginWorkspaceTransformGesture(self)
            
        case .changed:
            let translation = Vector(
                panGesture.translation(in: view))
            
            delegate?.onUpdateWorkspaceTransformGesture(
                self,
                anchorPosition: .zero,
                translation: translation,
                rotation: 0,
                scale: 1)
            
        default:
            delegate?.onEndWorkspaceTransformGesture(
                self,
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
        anchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        delegate?.onUpdateWorkspaceTransformGesture(
            self,
            anchorPosition: anchorPosition,
            translation: translation,
            rotation: rotation,
            scale: scale)
    }
    
    func onEndGesture(pinchFlickIn: Bool) {
        delegate?.onEndWorkspaceTransformGesture(
            self,
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
