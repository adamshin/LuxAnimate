//
//  EditorVC.swift
//

import UIKit
import MetalKit

private let canvasWidth = 1920
private let canvasHeight = 1080

class EditorVC: UIViewController {
    
    private let projectID: String
    
    private let metalView = FrameEditorMetalView()
    
    private let testRenderer = TestRenderer(
        canvasWidth: canvasWidth,
        canvasHeight: canvasHeight)
    
    private let viewTextureRenderer = MetalViewTextureRenderer()
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
        super.init(nibName: nil, bundle: nil)
        
//        renderer.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        render()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        metalView.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: CGFloat(canvasWidth) / UIScreen.main.scale,
                height: CGFloat(canvasHeight) / UIScreen.main.scale
            )
        )
        
        metalView.center = CGPoint(
            x: view.frame.midX,
            y: view.frame.midY)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .editorBackground
        
        view.addSubview(metalView)
        
        metalView.setDrawableSize(
            CGSize(width: canvasWidth, height: canvasHeight))
        
        metalView.delegate = self
    }
    
    // MARK: - Render
    
    private func render() {
        testRenderer.draw()
        
        let framebuffer = testRenderer.getFramebuffer()
        
        viewTextureRenderer.draw(
            texture: framebuffer,
            to: metalView.metalLayer)
    }
    
}

// MARK: - Delegates

extension EditorVC: FrameEditorMetalViewDelegate {
    
    func draw(in layer: CAMetalLayer) {
        render()
    }
    
}

extension EditorVC: FrameSceneRendererDelegate {
    
    func textureForDrawing(drawingID: String) -> MTLTexture? {
        return nil
    }
    
}
