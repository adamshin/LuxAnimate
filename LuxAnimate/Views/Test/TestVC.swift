//
//  TestVC.swift
//

import UIKit

private func generateTestScene(
    timestamp: Double
) -> TestScene {
    
    TestScene(
        layers: [
            TestScene.Layer(
                transform: .identity,
                contentSize: Size(1000, 1000),
                alpha: 1,
                content: .rect(
                    .init(color: .white))),
            
            TestScene.Layer(
                transform: 
                    Matrix3(translation: Vector(500 * sin(timestamp * 2), 0)),
                contentSize: Size(300, 300),
                alpha: 0.8,
                content: .rect(
                    .init(color: .brushBlue))),
            
            TestScene.Layer(
                transform:
                    Matrix3(translation: Vector(200, 200)) *
                    Matrix3(rotation: timestamp),
                contentSize: Size(300, 300),
                alpha: 1,
                content: .rect(
                    .init(color: .brushRed))),
        ])
}

class TestVC: UIViewController {
    
    private let metalView = TestMetalView()
    
    private let sceneRenderer = TestSceneRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
    private let displayLink = WrappedDisplayLink()
    private var needsDraw = false
    
    private var scene: TestScene?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(metalView)
        metalView.pinEdges()
        metalView.delegate = self
        
        displayLink.setCallback { [weak self] timestamp in
            self?.onFrame(timestamp: timestamp)
        }
    }
    
    // MARK: - Frame
    
    private func onFrame(timestamp: Double) {
        scene = generateTestScene(timestamp: timestamp)
        draw()
        
//        if needsDraw {
//            needsDraw = false
//            draw()
//        }
    }
    
    // MARK: - Render
    
    private func draw() {
        guard let scene else { return }
        
        guard let drawable = metalView
            .metalLayer.nextDrawable()
        else { return }

        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!

        sceneRenderer.draw(
            target: drawable.texture,
            commandBuffer: commandBuffer,
            scene: scene)

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
}

// MARK: - Delegates

extension TestVC: TestMetalViewDelegate {
    
    func onRequestDraw(_ view: TestMetalView) {
//        needsDraw = true
    }
    
}
