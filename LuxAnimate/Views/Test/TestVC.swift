//
//  TestVC.swift
//

import UIKit

class TestVC: UIViewController {
    
    private let metalView = TestMetalView()
    
    private let testRenderer = TestRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
//    private var needsDraw = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(metalView)
        metalView.pinEdges()
        metalView.delegate = self
    }
    
    // MARK: - Render
    
    private func draw() {
        guard let drawable = metalView
            .metalLayer.nextDrawable()
        else { return }

        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!

        testRenderer.draw(
            commandBuffer: commandBuffer,
            target: drawable.texture)

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
}

// MARK: - Delegates

extension TestVC: TestMetalViewDelegate {
    
    func onRequestDraw(_ view: TestMetalView) {
        draw()
    }
    
}
