//
//  MovableCanvasView.swift
//

import UIKit
import Geometry

private let fitToBoundsInset: CGFloat = 0

private let rotationSnapThreshold: Scalar =
    8 * .radiansPerDegree

// MARK: - MovableCanvasView

@MainActor
protocol MovableCanvasViewDelegate: AnyObject {
    
    func onUpdateCanvasTransform(
        _ v: MovableCanvasView,
        _ transform: MovableCanvasTransform)
}

class MovableCanvasView: UIView {
    
    weak var delegate: MovableCanvasViewDelegate?
    
    let canvasContentView = MovableCanvasExtendedHitAreaView()
    
    private weak var safeAreaReferenceView: UIView?
    
    private let multiGesture = CanvasMultiGestureRecognizer()
    private let panGesture = UIPanGestureRecognizer()
    
    private var baseCanvasTransform = MovableCanvasTransform()
    private var activeGestureCanvasTransform: MovableCanvasTransform?
    
    private var isCanvasFitToBounds = false
    
    var canvasSize = PixelSize(width: 0, height: 0) {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var minScale: Scalar = 1
    var maxScale: Scalar = 1
    
    var isSingleFingerPanEnabled: Bool = true {
        didSet {
            panGesture.isEnabled = isSingleFingerPanEnabled
        }
    }
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = true
        backgroundColor = .clear
        
        addSubview(canvasContentView)
        canvasContentView.frame = .zero
        canvasContentView.clipsToBounds = true
        canvasContentView.isUserInteractionEnabled = false
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
        
        canvasContentView.bounds = CGRect(
            origin: .zero,
            size: CGSize(
                width: canvasSize.width,
                height: canvasSize.height))
        
        canvasContentView.center = bounds.center
        
        if isCanvasFitToBounds,
            activeGestureCanvasTransform == nil
        {
            baseCanvasTransform = canvasTransformFittingToBounds()
            setCanvasTransform(baseCanvasTransform)
        }
        
        let canvasTransform =
            activeGestureCanvasTransform ??
            baseCanvasTransform
        delegate?.onUpdateCanvasTransform(self, canvasTransform)
    }
    
    // MARK: - Transform
    
    private func setCanvasTransform(
        _ transform: MovableCanvasTransform,
        animated: Bool = false,
        animDuration: CGFloat = 0.4
    ) {
        let matrix = transform.matrix()
        
        if animated {
            let timingFunction = CAMediaTimingFunction(
                controlPoints: 0.1, 0.0, 0.1, 1.0)
            
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(timingFunction)

            UIView.animate(withDuration: animDuration) {
                self.canvasContentView.transform = matrix.cgAffineTransform
            }
            
            CATransaction.commit()
            
        } else {
            canvasContentView.transform = matrix.cgAffineTransform
        }
        
        delegate?.onUpdateCanvasTransform(self, transform)
    }
    
    private func canvasTransformFittingToBounds()
    -> MovableCanvasTransform {
        
        let canvasWidth = Double(canvasSize.width)
        let canvasHeight = Double(canvasSize.height)
        
        guard canvasWidth > 0, canvasHeight > 0
        else { return MovableCanvasTransform() }
        
        let boundsReferenceView = safeAreaReferenceView ?? self
        
        let referenceBoundsCenter = convert(
            boundsReferenceView.bounds.center,
            from: boundsReferenceView)
        
        let centerOffset = 
            Vector(referenceBoundsCenter) -
            Vector(bounds.center)
        
        let availableWidth = boundsReferenceView.bounds.width 
            - fitToBoundsInset * 2
        let availableHeight = boundsReferenceView.bounds.height 
            - fitToBoundsInset * 2
        
        let xScaleToFit = availableWidth / canvasWidth
        let yScaleToFit = availableHeight / canvasHeight
        
        let scale = min(xScaleToFit, yScaleToFit)
        
        return MovableCanvasTransform(
            translation: centerOffset,
            rotation: 0,
            scale: scale)
    }
    
    private func canvasTransformSnapping(
        _ transform: MovableCanvasTransform
    ) -> MovableCanvasTransform {
        
        let canvasWidth = Double(canvasSize.width)
        let canvasHeight = Double(canvasSize.height)
        
        var snappedTransform = transform
        
        snappedTransform.snapScale(
            minScale: minScale,
            maxScale: maxScale)
        
        snappedTransform.snapRotation(
            threshold: rotationSnapThreshold)
        
        snappedTransform.snapTranslationToKeepRectContainingOrigin(
            x: -canvasWidth / 2,
            y: -canvasHeight / 2,
            width: canvasWidth,
            height: canvasHeight)
        
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
                initialAnchorPosition: .zero,
                translation: translation,
                rotation: 0,
                scale: 1)
            
        default:
            endMultiGesture(pinchFlickIn: false)
        }
    }
    
    // MARK: - Multi Gesture
    
    private func beginMultiGesture() {
        isCanvasFitToBounds = false
        activeGestureCanvasTransform = baseCanvasTransform
    }
    
    private func updateMultiGesture(
        initialAnchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) { 
        let anchor = Vector(
            initialAnchorPosition.x - bounds.width / 2,
            initialAnchorPosition.y - bounds.height / 2)
        
        var newTransform = baseCanvasTransform
        
        newTransform.applyScale(scale,
            minScale: 0,
            maxScale: maxScale,
            anchor: anchor)
        
        newTransform.applyRotation(rotation, anchor: anchor)
        
        newTransform.applyTranslation(translation)
        
        self.activeGestureCanvasTransform = newTransform
        setCanvasTransform(newTransform)
    }
    
    private func endMultiGesture(pinchFlickIn: Bool) {
        guard let activeGestureCanvasTransform else { return }
        
        if pinchFlickIn {
            isCanvasFitToBounds = true
            
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
    
    func fitCanvasToBounds(animated: Bool) {
        isCanvasFitToBounds = true
        
        layoutIfNeeded()
        
        baseCanvasTransform = canvasTransformFittingToBounds()
        activeGestureCanvasTransform = nil
        
        setCanvasTransform(
            baseCanvasTransform,
            animated: animated)
    }
    
    func setSafeAreaReferenceView(_ view: UIView) {
        self.safeAreaReferenceView = view
        handleChangeSafeAreaReferenceViewFrame()
    }
    
    func handleChangeSafeAreaReferenceViewFrame() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}

extension MovableCanvasView: CanvasMultiGestureRecognizerGestureDelegate {
    
    func onBeginGesture() {
        beginMultiGesture()
    }
    
    func onUpdateGesture(
        initialAnchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        updateMultiGesture(
            initialAnchorPosition: initialAnchorPosition,
            translation: translation,
            rotation: rotation,
            scale: scale)
    }
    
    func onEndGesture(
        finalAnchorPosition: Vector,
        pinchFlickIn: Bool
    ) {
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
