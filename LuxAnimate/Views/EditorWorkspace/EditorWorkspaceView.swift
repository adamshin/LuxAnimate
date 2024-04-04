//
//  EditorWorkspaceView.swift
//

import UIKit

private let canvasSize = CGSize(
    width: 1920,
    height: 1080)

private let minScale: Scalar = 0.1
private let maxScale: Scalar = 10.0

private let scalePixelateThreshold: Scalar = 1.0

private let rotationSnapThreshold: Scalar = 
    8 * .radiansPerDegree

class EditorWorkspaceView: UIView {
    
    private let canvasView = UIImageView()
    
    private let multiGesture = CanvasMultiGestureRecognizer()
    private let panGesture = UIPanGestureRecognizer()
    
    private var baseCanvasTransform = CanvasTransform()
    private var modifiedCanvasTransform: CanvasTransform?
    
    // MARK: - Initializer
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .editorBackground
        
        addSubview(canvasView)
        canvasView.backgroundColor = .white
        
        canvasView.frame = CGRect(
            origin: .zero,
            size: canvasSize)
        
        canvasView.image = .sampleCanvas
        canvasView.contentMode = .scaleAspectFill
        canvasView.clipsToBounds = true
        
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
        
        canvasView.center = CGPoint(
            x: bounds.midX,
            y: bounds.midY)
    }
    
    // MARK: - Handlers
    
    @objc private func onPan() {
        switch panGesture.state {
        case .began:
            beginGesture()
            
        case .changed:
            let translation = Vector(panGesture.translation(in: self))
            
            updateGesture(
                anchorLocation: .zero,
                translation: translation,
                rotation: 0,
                scale: 1)
            
        default:
            endGesture()
        }
    }
    
    // MARK: - Transform
    
    private func setCanvasTransform(
        _ transform: CanvasTransform,
        animated: Bool = false
    ) {
        if transform.scale >= scalePixelateThreshold {
            canvasView.layer.magnificationFilter = .nearest
        } else {
            canvasView.layer.magnificationFilter = .linear
        }
        
        let matrix = transform.matrix()
        
        if animated {
            UIView.animate(springDuration: 0.3) {
                canvasView.transform = matrix.cgAffineTransform
            }
        } else {
            canvasView.transform = matrix.cgAffineTransform
        }
    }
    
    private func snapCanvasTransform() {
        baseCanvasTransform.snapRotation(
            threshold: rotationSnapThreshold)
        
        baseCanvasTransform.snapTranslationToKeepRectInOrigin(
            x: -canvasSize.width / 2,
            y: -canvasSize.height / 2,
            width: canvasSize.width,
            height: canvasSize.height)
        
        setCanvasTransform(baseCanvasTransform, animated: true)
    }
    
    // MARK: - Gestures
    
    private func beginGesture() {
        modifiedCanvasTransform = baseCanvasTransform
    }
    
    private func updateGesture(
        anchorLocation: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        let anchor = Vector(
            anchorLocation.x - bounds.width / 2,
            anchorLocation.y - bounds.height / 2)
        
        var newTransform = baseCanvasTransform
        
        newTransform.applyScale(scale,
            min: minScale,
            max: maxScale,
            anchor: anchor)
        
        newTransform.applyRotation(rotation, anchor: anchor)
        
        newTransform.applyTranslation(translation)
        
        self.modifiedCanvasTransform = newTransform
        setCanvasTransform(newTransform)
    }
    
    private func endGesture() {
        guard let modifiedCanvasTransform else { return }
        
        baseCanvasTransform = modifiedCanvasTransform
        self.modifiedCanvasTransform = nil
        
        snapCanvasTransform()
    }
    
    // MARK: - Interface
    
    func fitCanvasToBounds(animated: Bool) {
        guard modifiedCanvasTransform == nil else { return }
        
        let xScaleToFit = bounds.width / canvasSize.width
        let yScaleToFit = bounds.height / canvasSize.height
        
        let scale = min(xScaleToFit, yScaleToFit)
        
        baseCanvasTransform = CanvasTransform(
            translation: .zero,
            rotation: 0,
            scale: scale)
        
        setCanvasTransform(baseCanvasTransform, animated: animated)
    }
    
}

// MARK: - Delegates

extension EditorWorkspaceView: CanvasMultiGestureRecognizerGestureDelegate {
    
    func onBeginGesture() {
        beginGesture()
    }
    
    func onUpdateGesture(
        anchorLocation: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        updateGesture(
            anchorLocation: anchorLocation,
            translation: translation,
            rotation: rotation,
            scale: scale)
    }
    
    func onEndGesture() { 
        endGesture()
    }
    
}

extension EditorWorkspaceView: UIGestureRecognizerDelegate {
    
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
