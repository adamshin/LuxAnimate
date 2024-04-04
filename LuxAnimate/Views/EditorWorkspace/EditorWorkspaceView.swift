//
//  EditorWorkspaceView.swift
//

import UIKit

private let canvasSize = CGSize(width: 500, height: 500)

private let minScale: Scalar = 0.5
private let maxScale: Scalar = 5.0

class EditorWorkspaceView: UIView {
    
    enum CanvasState {
        
        case normal(transform: CanvasTransform)
        
        case gesture(
            baseTransform: CanvasTransform,
            modifiedTransform: CanvasTransform)
        
    }
    
    private let canvasView = UIImageView()
    
    private let multiGesture = CanvasMultiGestureRecognizer()
    private let panGesture = UIPanGestureRecognizer()
    
    private var canvasState: CanvasState =
        .normal(transform: CanvasTransform())
    
    // MARK: - Initializer
    
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor(white: 0.3, alpha: 1)
        
        addSubview(canvasView)
        canvasView.backgroundColor = .white
        
        canvasView.frame = CGRect(
            origin: .zero,
            size: canvasSize)
        
        canvasView.image = UIImage(named: "pika")
        canvasView.contentMode = .scaleAspectFill
        
        addGestureRecognizer(multiGesture)
        multiGesture.gestureDelegate = self
        
        addGestureRecognizer(panGesture)
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
    
    private func setCanvasTransform(_ transform: CanvasTransform) {
        let matrix = transform.matrix()
        canvasView.transform = matrix.cgAffineTransform
    }
    
    // MARK: - Gestures
    
    private func beginGesture() {
        guard case let .normal(transform) = canvasState
        else { return }
        
        canvasState = .gesture(
            baseTransform: transform,
            modifiedTransform: transform)
    }
    
    private func updateGesture(
        anchorLocation: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        guard case let .gesture(baseTransform, _) = canvasState
        else { return }
        
        let anchor = Vector(
            anchorLocation.x - bounds.width / 2,
            anchorLocation.y - bounds.height / 2)
//        let anchor = anchorLocation
        
        let clampedScale = clamp(scale,
            min: minScale / baseTransform.scale,
            max: maxScale / baseTransform.scale)
        
        var modifiedTransform = baseTransform
        
        modifiedTransform.applyScale(clampedScale, anchor: anchor)
        modifiedTransform.applyRotation(rotation, anchor: anchor)
        modifiedTransform.applyTranslation(translation)
        
        canvasState = .gesture(
            baseTransform: baseTransform,
            modifiedTransform: modifiedTransform)
        
        setCanvasTransform(modifiedTransform)
    }
    
    func endGesture() {
        guard case let .gesture(_, modifiedTransform) = canvasState
        else { return }
        
        canvasState = .normal(transform: modifiedTransform)
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
