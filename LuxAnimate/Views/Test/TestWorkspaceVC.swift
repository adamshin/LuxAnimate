//
//  TestWorkspaceVC.swift
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
                transform: Matrix3(translation: Vector(-400, -200)),
                contentSize: Size(100, 500),
                alpha: 1,
                content: .rect(
                    .init(color: .brushGreen))),
            
            TestScene.Layer(
                transform: .identity,
                contentSize: Size(300, 300),
                alpha: 0.8,
                content: .rect(
                    .init(color: .brushRed))),
            
            TestScene.Layer(
                transform: Matrix3(translation: Vector(100, 100)),
                contentSize: Size(300, 300),
                alpha: 1,
                content: .rect(
                    .init(color: .brushBlue))),
        ])
}

class TestWorkspaceVC: UIViewController {
    
    private let metalView = TestWorkspaceMetalView()
    private let overlayVC = TestWorkspaceOverlayVC()
    
    private let transformManager = TestWorkspaceTransformManager()
    
    private let sceneRenderer = TestWorkspaceRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
    private let displayLink = WrappedDisplayLink()
    
    private var scene: TestScene?
    private var workspaceTransform: Matrix3 = .identity
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(metalView)
        metalView.pinEdges()
        metalView.delegate = self
        
//        addChild(overlayVC, to: view)
//        overlayVC.delegate = self
//        
//        transformManager.delegate = self
        
        displayLink.setCallback { [weak self] timestamp in
            self?.onFrame(timestamp: timestamp)
        }
    }
    
    // MARK: - Frame
    
    private func onFrame(timestamp: Double) {
        scene = generateTestScene(timestamp: timestamp)
        
        draw()
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
            workspaceTransform: .identity,//workspaceTransform,
            scene: scene)

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
}

// MARK: - Delegates

extension TestWorkspaceVC: TestWorkspaceMetalViewDelegate {
    
    func onRequestDraw(_ view: TestWorkspaceMetalView) { }
    
}

extension TestWorkspaceVC: TestWorkspaceOverlayVCDelegate {
    
    func onBeginWorkspaceTransformGesture(
        _ vc: TestWorkspaceOverlayVC
    ) {
        transformManager.handleBeginTransformGesture()
    }
    
    func onUpdateWorkspaceTransformGesture(
        _ vc: TestWorkspaceOverlayVC,
        anchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        transformManager.handleUpdateTransformGesture(
            anchorPosition: anchorPosition,
            translation: translation,
            rotation: rotation,
            scale: scale)
    }
    
    func onEndWorkspaceTransformGesture(
        _ vc: TestWorkspaceOverlayVC,
        pinchFlickIn: Bool
    ) {
        transformManager.handleEndTransformGesture(
            pinchFlickIn: pinchFlickIn)
    }
    
}

extension TestWorkspaceVC: TestWorkspaceTransformManagerDelegate {
    
    func onUpdateTransform(
        _ m: TestWorkspaceTransformManager,
        transform: TestWorkspaceTransform
    ) {
//        workspaceTransform = transform.matrix()
    }
    
}
