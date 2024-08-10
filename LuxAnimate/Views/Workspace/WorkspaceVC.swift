//
//  WorkspaceVC.swift
//

import UIKit

class WorkspaceVC: UIViewController {
    
    private let metalView = MetalView()
    
    private let testRenderer = TestRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
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
    }
    
    // MARK: - Rendering
    
    private func draw() {
        guard let drawable = metalView
            .metalLayer.nextDrawable()
        else { return }
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: drawable.texture,
            color: .white)
        
        testRenderer.draw(
            commandBuffer: commandBuffer,
            target: drawable.texture)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
}

// MARK: - Delegates

extension WorkspaceVC: MetalViewDelegate {
    
    func draw(in layer: CAMetalLayer) {
        draw()
    }
    
}
