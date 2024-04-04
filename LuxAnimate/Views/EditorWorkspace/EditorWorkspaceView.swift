//
//  EditorWorkspaceView.swift
//

import UIKit

private let canvasSize = CGSize(width: 500, height: 500)

private let minScale: Scalar = 0.5
private let maxScale: Scalar = 5.0

class EditorWorkspaceView: UIView {
    
    private let canvasView = UIImageView()
    
    private let multiGesture = CanvasMultiGestureRecognizer()
    private let panGesture = UIPanGestureRecognizer()
    
    private var baseCanvasTransform = CanvasTransform()
    private var modifiedCanvasTransform: CanvasTransform?
    
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
    
    private func setCanvasTransform(
        _ transform: CanvasTransform,
        animated: Bool = false
    ) {
        let matrix = transform.matrix()
        
        if animated {
            UIView.animate(springDuration: 0.2) {
                canvasView.transform = matrix.cgAffineTransform
            }
        } else {
            canvasView.transform = matrix.cgAffineTransform
        }
    }
    
    private func snapCanvasTransform() {
        baseCanvasTransform.snapRotation()
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
        
        // TODO: Adjust translation so image rect always stays onscreen
        
        self.modifiedCanvasTransform = newTransform
        setCanvasTransform(newTransform)
    }
    
    func endGesture() {
        guard let modifiedCanvasTransform else { return }
        
        baseCanvasTransform = modifiedCanvasTransform
        self.modifiedCanvasTransform = nil
        
        snapCanvasTransform()
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
