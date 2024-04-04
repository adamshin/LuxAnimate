//
//  EditorWorkspaceView.swift
//

import UIKit

private let canvasSize = CGSize(width: 500, height: 500)

private let minScale: Scalar = 0.5
private let maxScale: Scalar = 3.0

class EditorWorkspaceView: UIView {
    
    enum CanvasState {
        
        case normal(transform: CanvasTransform)
        
        case gesture(
            baseTransform: CanvasTransform,
            modifiedTransform: CanvasTransform)
        
    }
    
    private let canvasView = UIImageView()
    private let multiGesture = CanvasMultiGestureRecognizer()
    
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
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        canvasView.center = CGPoint(
            x: bounds.midX,
            y: bounds.midY)
    }
    
    // MARK: - Transform
    
    private func setCanvasTransform(_ transform: CanvasTransform) {
        let matrix = transform.matrix()
        canvasView.transform = matrix.cgAffineTransform
    }
    
}

// MARK: - Delegates

extension EditorWorkspaceView: CanvasMultiGestureRecognizerGestureDelegate {
    
    func onBeginGesture() {
        guard case let .normal(transform) = canvasState
        else { return }
        
        canvasState = .gesture(
            baseTransform: transform,
            modifiedTransform: transform)
    }
    
    func onUpdateGesture(
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
    
    func onEndGesture() { 
        guard case let .gesture(_, modifiedTransform) = canvasState
        else { return }
        
        canvasState = .normal(transform: modifiedTransform)
    }
    
}
