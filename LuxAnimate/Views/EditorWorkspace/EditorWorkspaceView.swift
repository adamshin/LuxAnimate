//
//  EditorWorkspaceView.swift
//

import UIKit

private let canvasSize = CGSize(width: 500, height: 500)

class EditorWorkspaceView: UIView {
    
    enum CanvasState {
        
        case normal(transform: Matrix3)
        
        case gesture(
            baseTransform: Matrix3,
            gestureTransform: Matrix3)
        
    }
    
    private let canvasView = UIView()
    private let multiGesture = CanvasMultiGestureRecognizer()
    
    private var canvasState: CanvasState =
        .normal(transform: .identity)
    
    // MARK: - Initializer
    
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor(white: 0.3, alpha: 1)
        
        addSubview(canvasView)
        canvasView.backgroundColor = .white
        
        canvasView.frame = CGRect(
            origin: .zero,
            size: canvasSize)
        
        let imageView = UIImageView(image: UIImage(named: "pika"))
        canvasView.addSubview(imageView)
        imageView.pinEdges()
        imageView.contentMode = .scaleAspectFill
        
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
    
    private func setCanvasTransform(_ transform: Matrix3) {
        canvasView.transform = transform.cgAffineTransform
    }
    
}

// MARK: - Delegates

extension EditorWorkspaceView: CanvasMultiGestureRecognizerGestureDelegate {
    
    func onBeginGesture() {
        guard case let .normal(transform) = canvasState
        else { return }
        
        canvasState = .gesture(
            baseTransform: transform,
            gestureTransform: .identity)
    }
    
    func onUpdateGesture(
        anchorLocation: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        guard case let .gesture(
            baseTransform,
            _
        ) = canvasState
        else { return }
        
        let anchorLocationRelativeToCenter = Vector(
            anchorLocation.x - bounds.width / 2,
            anchorLocation.x - bounds.width / 2)
        
        let gestureTransform = gestureTransform(
            anchorLocation: anchorLocationRelativeToCenter,
            translation: translation,
            rotation: rotation,
            scale: scale)
        
        let transform = gestureTransform * baseTransform
        
        canvasState = .gesture(
            baseTransform: baseTransform,
            gestureTransform: gestureTransform)
        
        setCanvasTransform(transform)
    }
    
    func onEndGesture() { 
        guard case let .gesture(
            baseTransform,
            gestureTransform
        ) = canvasState
        else { return }
        
        let transform = gestureTransform * baseTransform
        canvasState = .normal(transform: transform)
    }
    
}

// MARK: - Gesture Transform

private func gestureTransform(
    anchorLocation: Vector,
    translation: Vector,
    rotation: Scalar,
    scale: Scalar
) -> Matrix3 {
    
    // Move anchor to origin
    let t1 = Matrix3(translation: -anchorLocation)
    
    // Scale
    var t2 = Matrix3(scale: Vector2(scale, scale))
    
    // Rotate
    let t3 = Matrix3(rotation: rotation)
    
    // Move anchor back
    let t4 = Matrix3(translation: anchorLocation)
    
    // Translate
    let t5 = Matrix3(translation: translation)
    
    return t5 * t4 * t3 * t2 * t1
}
