//
//  TestVC.swift
//

import UIKit

class TestVC: UIViewController {
        
    private let canvasView = MovableCanvasView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .editorBackground
        
        view.addSubview(canvasView)
        canvasView.pinEdges()
        canvasView.delegate = self
        
        let imageView = UIImageView(image: .sampleCanvas)
        canvasView.canvasContentView.addSubview(imageView)
        imageView.pinEdges()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        canvasView.fitCanvasToBounds(animated: false)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        canvasView.fitCanvasToBounds(animated: false)
//    }
    
}

// MARK: - Delegates

extension TestVC: MovableCanvasViewDelegate {
    
    func contentSize(_ v: MovableCanvasView) -> Size {
        Size(1920, 1080)
    }
    
    func minScale(_ v: MovableCanvasView) -> Scalar {
        0.1
    }
    
    func maxScale(_ v: MovableCanvasView) -> Scalar {
        10
    }
    
    func onUpdateTransform(
        _ v: MovableCanvasView,
        _ transform: MovableCanvasTransform
    ) { }
    
}
