//
//  TestWorkspaceVC.swift
//

import UIKit

private let contentSize = Size(1000, 1000)

private let minScale: Scalar = 0.1
private let maxScale: Scalar = 30

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
        
        addChild(overlayVC, to: view)
        overlayVC.delegate = self
        
        transformManager.delegate = self
        transformManager.setContentSize(contentSize)
        transformManager.setMinScale(minScale)
        transformManager.setMaxScale(maxScale)
        
        displayLink.setCallback { [weak self] timestamp in
            self?.onFrame(timestamp: timestamp)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        transformManager.setViewportSize(
            Size(
                metalView.bounds.width * metalView.contentScaleFactor,
                metalView.bounds.height * metalView.contentScaleFactor))
    }
    
    // MARK: - Frame
    
    private func onFrame(timestamp: Double) {
        scene = TestScene.generate(timestamp: timestamp)
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
            workspaceTransform: workspaceTransform,
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
            anchorPosition: anchorPosition * metalView.contentScaleFactor,
            translation: translation * metalView.contentScaleFactor,
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
        workspaceTransform = transform.matrix()
    }
    
}
