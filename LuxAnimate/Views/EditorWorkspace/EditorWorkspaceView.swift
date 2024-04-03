//
//  EditorWorkspaceView.swift
//

import UIKit

private let canvasSize = CGSize(width: 500, height: 500)

class EditorWorkspaceView: UIView {
    
    private let canvasView = UIView()
    private let panGesture = CanvasMultiGestureRecognizer()
    
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
        
        addGestureRecognizer(panGesture)
        panGesture.gestureDelegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        canvasView.center = CGPoint(
            x: bounds.midX,
            y: bounds.midY)
    }
    
}

// MARK: - Delegates

extension EditorWorkspaceView: CanvasMultiGestureRecognizerGestureDelegate {
    
    func onBeginGesture() {
//        print("Begin pan")
    }
    
    func onUpdateGesture(
        initialAnchorLocation: Vector,
        translation: Vector?,
        rotation: Scalar?,
        scale: Scalar?
    ) {
//        print("Update pan")
    }
    
    func onEndGesture() {
//        print("End pan")
    }
    
}
