//
//  TestWorkspaceVC.swift
//

import UIKit

private let canvasSize = PixelSize(1920, 1080)

private let minScale: Scalar = 0.1
private let maxScale: Scalar = 30

class TestWorkspaceVC: UIViewController {
    
    private let metalView = TestWorkspaceMetalView()
    private let overlayVC = TestWorkspaceOverlayVC()
    
    private let brush: Brush
    
    private let brushEngine = BrushEngine(
        canvasSize: canvasSize,
        brushMode: .paint)
    
    private let workspaceTransformManager = TestWorkspaceTransformManager()
    
    private let workspaceRenderer = TestWorkspaceRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
    private lazy var displayLink = CAMetalDisplayLink(
        metalLayer: metalView.metalLayer)
    
    // MARK: - Init
    
    init() {
        brush = try! Brush(
            configuration: AppConfig.roundBrushConfig)
        
        super.init(nibName: nil, bundle: nil)
        
        brushEngine.delegate = self
        
        workspaceTransformManager.delegate = self
        workspaceTransformManager.setMinScale(minScale)
        workspaceTransformManager.setMaxScale(maxScale)
        workspaceTransformManager.setContentSize(Size(
            Double(canvasSize.width),
            Double(canvasSize.height)))
        
        workspaceTransformManager.fitContentToViewport()
        
        displayLink.delegate = self
        displayLink.preferredFrameLatency = 1
        displayLink.add(to: .main, forMode: .common)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        metalView.delegate = self
        view.addSubview(metalView)
        metalView.pinEdges()
        
        overlayVC.delegate = self
        addChild(overlayVC, to: view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        workspaceTransformManager.setViewportSize(
            Size(
                metalView.bounds.width,
                metalView.bounds.height))
    }
    
    // MARK: - Brush Engine
    
    private func clearCanvas() {
        let texture = try! TextureCreator
            .createEmptyTexture(
                size: canvasSize,
                mipMapped: false)
        
        brushEngine.setCanvasTexture(texture)
    }
    
    // MARK: - Render
    
    private func draw(drawable: CAMetalDrawable) {
        let layerSize = Size(
            Double(canvasSize.width),
            Double(canvasSize.height))
        
        let scene = TestScene(layers: [
            TestScene.Layer(
                transform: .identity,
                contentSize: layerSize,
                alpha: 1,
                content: .rect(.init(
                    color: .white
                ))
            ),
            TestScene.Layer(
                transform: .identity,
                contentSize: layerSize,
                alpha: 1,
                content: .drawing(.init(
                    texture: brushEngine.activeCanvasTexture
                ))
            ),
        ])
        
        let workspaceTransform =
            workspaceTransformManager.transform()
        
        let viewportSize = Size(
            metalView.bounds.width,
            metalView.bounds.height)
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        workspaceRenderer.draw(
            target: drawable.texture,
            commandBuffer: commandBuffer,
            viewportSize: viewportSize,
            workspaceTransform: workspaceTransform,
            scene: scene)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
}

// MARK: - Delegates

extension TestWorkspaceVC: CAMetalDisplayLinkDelegate {
    
    func metalDisplayLink(
        _ link: CAMetalDisplayLink,
        needsUpdate update: CAMetalDisplayLink.Update
    ) {
        workspaceTransformManager.onFrame()
        brushEngine.onFrame()
        
        draw(drawable: update.drawable)
    }
    
}

extension TestWorkspaceVC: TestWorkspaceMetalViewDelegate {
    
    func onRequestDraw(_ view: TestWorkspaceMetalView) { }
    
}

extension TestWorkspaceVC: TestWorkspaceTransformManagerDelegate {
    
    func onUpdateTransform(
        _ m: TestWorkspaceTransformManager
    ) { }
    
}

extension TestWorkspaceVC: TestWorkspaceOverlayVCDelegate {
    
    func onBeginWorkspaceTransformGesture(
        _ vc: TestWorkspaceOverlayVC
    ) {
        workspaceTransformManager.handleBeginTransformGesture()
    }
    
    func onUpdateWorkspaceTransformGesture(
        _ vc: TestWorkspaceOverlayVC,
        initialAnchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        workspaceTransformManager.handleUpdateTransformGesture(
            initialAnchorPosition: initialAnchorPosition,
            translation: translation,
            rotation: rotation,
            scale: scale)
    }
    
    func onEndWorkspaceTransformGesture(
        _ vc: TestWorkspaceOverlayVC,
        finalAnchorPosition: Vector,
        pinchFlickIn: Bool
    ) {
        workspaceTransformManager.handleEndTransformGesture(
            finalAnchorPosition: finalAnchorPosition,
            pinchFlickIn: pinchFlickIn)
    }
    
    func onSelectUndo(_ vc: TestWorkspaceOverlayVC) {
        clearCanvas()
    }
    
    func onSelectRedo(_ vc: TestWorkspaceOverlayVC) { 
        clearCanvas()
    }
    
    func onBeginBrushStroke(
        _ vc: TestWorkspaceOverlayVC,
        quickTap: Bool
    ) {
        brushEngine.beginStroke(
            brush: brush,
            color: .brushBlack,
            scale: 0.1,
            smoothing: 0,
            quickTap: quickTap)
    }
    
    func onUpdateBrushStroke(
        _ vc: TestWorkspaceOverlayVC,
        stroke: BrushGestureRecognizer.Stroke
    ) {
        let viewportSize = Size(
            metalView.bounds.width,
            metalView.bounds.height)
        
        let canvasSize = Size(
            Double(canvasSize.width),
            Double(canvasSize.height))
        
        let workspaceTransform =
            workspaceTransformManager.transform()
        
        let inputStroke = TestBrushStrokeAdapter.convert(
            stroke: stroke,
            viewportSize: viewportSize,
            canvasSize: canvasSize,
            workspaceTransform: workspaceTransform)
        
        brushEngine.updateStroke(inputStroke: inputStroke)
    }
    
    func onEndBrushStroke(
        _ vc: TestWorkspaceOverlayVC
    ) {
        brushEngine.endStroke()
    }
    
    func onCancelBrushStroke(
        _ vc: TestWorkspaceOverlayVC
    ) {
        brushEngine.cancelStroke()
    }
    
}

extension TestWorkspaceVC: BrushEngineDelegate {
    
    func onUpdateActiveCanvasTexture(
        _ e: BrushEngine
    ) { }
    
    func onFinalizeStroke(
        _ e: BrushEngine,
        canvasTexture: MTLTexture
    ) { }
    
}
