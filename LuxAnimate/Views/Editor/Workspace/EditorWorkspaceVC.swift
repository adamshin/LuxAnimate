//
//  EditorWorkspaceVC.swift
//

import UIKit

protocol EditorWorkspaceVCDelegate: AnyObject {
    func onRequestDraw(_ vc: EditorWorkspaceVC)
}

class EditorWorkspaceVC: UIViewController {
    
    weak var delegate: EditorWorkspaceVCDelegate?
    
    private let metalView = MetalView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(metalView)
        metalView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        metalView.frame = view.bounds
        
        let scale = metalView.contentScaleFactor
        let drawableSize = CGSize(
            width: metalView.bounds.width * scale,
            height: metalView.bounds.height * scale)
        
        metalView.setDrawableSize(drawableSize)
        delegate?.onRequestDraw(self)
    }
    
    // MARK: - Rendering
    
//    private func draw() {
//        guard let drawable = metalView
//            .metalLayer.nextDrawable()
//        else { return }
//        
//        let commandBuffer = MetalInterface.shared
//            .commandQueue.makeCommandBuffer()!
//        
//        testRenderer.draw(
//            commandBuffer: commandBuffer,
//            target: drawable.texture)
//        
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
    
}

// MARK: - Delegates

extension EditorWorkspaceVC: MetalViewDelegate {
    
    func draw(in layer: CAMetalLayer) {
        delegate?.onRequestDraw(self)
    }
    
}
