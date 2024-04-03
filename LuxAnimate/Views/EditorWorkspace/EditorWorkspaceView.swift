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
        
        addGestureRecognizer(panGesture)
        panGesture.panDelegate = self
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

extension EditorWorkspaceView: CanvasMultiGestureRecognizerPanDelegate {
    
    func onBeginPan() {
//        print("Begin pan")
    }
    
    func onUpdatePan(
        initialAnchorLocation: Vector,
        translation: Vector?,
        rotation: Scalar?,
        scale: Scalar?
    ) {
//        print("Update pan")
    }
    
    func onEndPan() {
//        print("End pan")
    }
    
}
