//
//  MovableCanvasView.swift
//

import UIKit

private let rotationSnapThreshold: Scalar =
    8 * .radiansPerDegree

// MARK: - MovableCanvasView

protocol MovableCanvasViewDelegate: AnyObject {
    
    func contentSize(_ v: MovableCanvasView) -> Size
    func minScale(_ v: MovableCanvasView) -> Scalar
    func maxScale(_ v: MovableCanvasView) -> Scalar
    
    func onUpdateTransform(
        _ v: MovableCanvasView,
        _ transform: MovableCanvasTransform)
}

class MovableCanvasView: UIView {
    
    weak var delegate: MovableCanvasViewDelegate?
    
    let canvasContentView = MovableCanvasExtendedHitAreaView()
    
    private let multiGesture = CanvasMultiGestureRecognizer()
    private let panGesture = UIPanGestureRecognizer()
    
    private var baseCanvasTransform = MovableCanvasTransform()
    private var activeGestureCanvasTransform: MovableCanvasTransform?
    
    var singleFingerPanEnabled: Bool = true {
        didSet {
            panGesture.isEnabled = singleFingerPanEnabled
        }
    }
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        
        addSubview(canvasContentView)
        canvasContentView.frame = .zero
        canvasContentView.clipsToBounds = true
        canvasContentView.backgroundColor = .clear
        
        addGestureRecognizer(multiGesture)
        multiGesture.gestureDelegate = self
        
        addGestureRecognizer(panGesture)
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(onPan))
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let canvasSize = delegate?.contentSize(self) ?? Size(1, 1)
        
        canvasContentView.bounds = CGRect(
            origin: .zero,
            size: CGSize(canvasSize))
        canvasContentView.center = bounds.center
        
        let canvasTransform =
            activeGestureCanvasTransform ??
            baseCanvasTransform
        delegate?.onUpdateTransform(self, canvasTransform)
    }
    
    // MARK: - Transform
    
    private func setCanvasTransform(
        _ transform: MovableCanvasTransform,
        animated: Bool = false,
        animDuration: CGFloat = 0.3
    ) {
        let matrix = transform.matrix()
        
        if animated {
            UIView.animate(springDuration: animDuration) {
                canvasContentView.transform = matrix.cgAffineTransform
            }
        } else {
            canvasContentView.transform = matrix.cgAffineTransform
        }
        
        delegate?.onUpdateTransform(self, transform)
    }
    
    private func canvasTransformFittingToBounds()
    -> MovableCanvasTransform {
        
        guard let canvasSize = delegate?.contentSize(self)
        else { return MovableCanvasTransform() }
        
        let xScaleToFit = bounds.width / canvasSize.width
        let yScaleToFit = bounds.height / canvasSize.height
        
        let scale = min(xScaleToFit, yScaleToFit)
        
        return MovableCanvasTransform(
            translation: .zero,
            rotation: 0,
            scale: scale)
    }
    
    private func canvasTransformSnapping(
        _ transform: MovableCanvasTransform
    ) -> MovableCanvasTransform {
        
        guard let canvasSize = delegate?.contentSize(self)
        else { return MovableCanvasTransform() }
        
        var snappedTransform = transform
        
        snappedTransform.snapRotation(
            threshold: rotationSnapThreshold)
        
        snappedTransform.snapTranslationToKeepRectContainingOrigin(
            x: -canvasSize.width / 2,
            y: -canvasSize.height / 2,
            width: canvasSize.width,
            height: canvasSize.height)
        
        return snappedTransform
    }
    
    // MARK: - Pan Gesture
    
    @objc private func onPan() {
        switch panGesture.state {
        case .began:
            beginMultiGesture()
            
        case .changed:
            let translation = Vector(
                panGesture.translation(in: self))
            
            updateMultiGesture(
                anchorPosition: .zero,
                translation: translation,
                rotation: 0,
                scale: 1)
            
        default:
            endMultiGesture(pinchFlickIn: false)
        }
    }
    
    // MARK: - Multi Gesture
    
    private func beginMultiGesture() {
        activeGestureCanvasTransform = baseCanvasTransform
    }
    
    private func updateMultiGesture(
        anchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        let minScale = delegate?.minScale(self) ?? 1
        let maxScale = delegate?.maxScale(self) ?? 1
        
        let anchor = Vector(
            anchorPosition.x - bounds.width / 2,
            anchorPosition.y - bounds.height / 2)
        
        var newTransform = baseCanvasTransform
        
        newTransform.applyScale(scale,
            min: minScale,
            max: maxScale,
            anchor: anchor)
        
        newTransform.applyRotation(rotation, anchor: anchor)
        
        newTransform.applyTranslation(translation)
        
        self.activeGestureCanvasTransform = newTransform
        setCanvasTransform(newTransform)
    }
    
    private func endMultiGesture(pinchFlickIn: Bool) {
        guard let activeGestureCanvasTransform else { return }
        
        if pinchFlickIn {
            self.activeGestureCanvasTransform = nil
            baseCanvasTransform = canvasTransformFittingToBounds()
            
            setCanvasTransform(
                baseCanvasTransform,
                animated: true,
                animDuration: 0.4)
            
        } else {
            self.activeGestureCanvasTransform = nil
            baseCanvasTransform = canvasTransformSnapping(
                activeGestureCanvasTransform)
            
            setCanvasTransform(
                baseCanvasTransform,
                animated: true)
        }
    }
    
    // MARK: - Interface
    
    func setNeedsCanvasSizeUpdate() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func fitCanvasToBounds(animated: Bool) {
        layoutIfNeeded()
        
        guard activeGestureCanvasTransform == nil else { return }
        
        baseCanvasTransform = canvasTransformFittingToBounds()
        
        setCanvasTransform(
            baseCanvasTransform,
            animated: animated)
    }
    
}

extension MovableCanvasView: CanvasMultiGestureRecognizerGestureDelegate {
    
    func onBeginGesture() {
        beginMultiGesture()
    }
    
    func onUpdateGesture(
        anchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        updateMultiGesture(
            anchorPosition: anchorPosition,
            translation: translation,
            rotation: rotation,
            scale: scale)
    }
    
    func onEndGesture(pinchFlickIn: Bool) {
        endMultiGesture(pinchFlickIn: pinchFlickIn)
    }
    
}

extension MovableCanvasView: UIGestureRecognizerDelegate {
    
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

// MARK: - MovableCanvasExtendedHitAreaView

class MovableCanvasExtendedHitAreaView: UIView {
    
    override func hitTest(
        _ point: CGPoint, 
        with event: UIEvent?
    ) -> UIView? {
        self
    }
    
}
