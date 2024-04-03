//
//  EditorWorkspaceView.swift
//

import UIKit

private let canvasSize = CGSize(width: 500, height: 500)

class EditorWorkspaceView: UIView {
    
    enum CanvasState {
        
        case normal(transform: CanvasTransform)
        
        case gesture(
            baseTransform: CanvasTransform,
            gestureTransform: CanvasTransform)
        
    }
    
    private let canvasView = UIView()
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
    
    private func applyTransformToCanvasView(
        _ transform: CanvasTransform
    ) {
        var affineTransform = CGAffineTransform.identity
        
        affineTransform = affineTransform.translatedBy(
            x: transform.translation.x,
            y: transform.translation.y)
        
        affineTransform = affineTransform.rotated(
            by: -transform.rotation)
        
        affineTransform = affineTransform.scaledBy(
            x: transform.scale,
            y: transform.scale)
        
        canvasView.transform = affineTransform
        
        print(transform.translation)
    }
    
}

// MARK: - Delegates

extension EditorWorkspaceView: CanvasMultiGestureRecognizerGestureDelegate {
    
    func onBeginGesture() {
        guard case let .normal(transform) = canvasState
        else { return }
        
        canvasState = .gesture(
            baseTransform: transform,
            gestureTransform: CanvasTransform())
    }
    
    func onUpdateGesture(
        initialAnchorLocation: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        guard case let .gesture(
            baseTransform,
            _
        ) = canvasState
        else { return }
        
        let newGestureTransform = CanvasTransform(
            translation: translation,
            rotation: rotation,
            scale: scale)
        
        let canvasTransform = baseTransform
            .applying(newGestureTransform)
        
        canvasState = .gesture(
            baseTransform: baseTransform,
            gestureTransform: newGestureTransform)
        
        applyTransformToCanvasView(canvasTransform)
    }
    
    func onEndGesture() { 
        guard case let .gesture(
            baseTransform,
            gestureTransform
        ) = canvasState
        else { return }
        
        let canvasTransform = baseTransform
            .applying(gestureTransform)
        
        canvasState = .normal(transform: canvasTransform)
    }
    
}
