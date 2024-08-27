//
//  TestEditorWorkspaceVC.swift
//

import UIKit
import Metal

private let minZoomScale: Scalar = 0.1
private let maxZoomScale: Scalar = 30

protocol TestEditorWorkspaceVCDelegate: AnyObject {
    
    func onFrame(
        _ vc: TestEditorWorkspaceVC,
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: TestWorkspaceTransform)
    
    func onSelectUndo(_ vc: TestEditorWorkspaceVC)
    func onSelectRedo(_ vc: TestEditorWorkspaceVC)
    
}

class TestEditorWorkspaceVC: UIViewController {
    
    weak var delegate: TestEditorWorkspaceVCDelegate?
    
    private let metalView = TestWorkspaceMetalView()
    private let overlayView = TestWorkspaceOverlayView()
    
    private let workspaceTransformManager = TestWorkspaceTransformManager()
    
    private lazy var displayLink = CAMetalDisplayLink(
        metalLayer: metalView.metalLayer)
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        displayLink.delegate = self
        displayLink.preferredFrameLatency = 1
        displayLink.add(to: .main, forMode: .common)
        
        workspaceTransformManager.delegate = self
        workspaceTransformManager.setMinScale(minZoomScale)
        workspaceTransformManager.setMaxScale(maxZoomScale)
        workspaceTransformManager.fitContentToViewport()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        metalView.delegate = self
        overlayView.delegate = self
        
        view.addSubview(metalView)
        view.addSubview(overlayView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        metalView.frame = view.bounds
        overlayView.frame = view.bounds
        
        workspaceTransformManager.setViewportSize(
            Size(
                metalView.bounds.width,
                metalView.bounds.height))
    }
    
    // MARK: - Interface
    
    func setContentSize(_ contentSize: Size) {
        workspaceTransformManager
            .setContentSize(contentSize)
    }
    
    // MARK: - Brush Engine
    
//    private func clearCanvas() {
//        let texture = try! TextureCreator
//            .createEmptyTexture(
//                size: layerContentSize,
//                mipMapped: false)
//        
//        brushEngine.setCanvasTexture(texture)
//    }
    
    // MARK: - Render
    
//    private func draw(drawable: CAMetalDrawable) {
//        let sceneSize = Size(
//            Double(sceneContentSize.width),
//            Double(sceneContentSize.height))
//        
//        let layerSize = Size(
//            Double(layerContentSize.width),
//            Double(layerContentSize.height))
//        
//        let scene = TestScene(layers: [
//            TestScene.Layer(
//                transform: .identity,
//                contentSize: sceneSize,
//                alpha: 1,
//                content: .rect(.init(
//                    color: .brushBlue
//                ))
//            ),
//            TestScene.Layer(
//                transform: layerTransform,
//                contentSize: layerSize,
//                alpha: 1,
//                content: .rect(.init(
//                    color: .white
//                ))
//            ),
//            TestScene.Layer(
//                transform: layerTransform,
//                contentSize: layerSize,
//                alpha: 1,
//                content: .drawing(.init(
//                    texture: brushEngine.activeCanvasTexture
//                ))
//            ),
//        ])
//        
//        let workspaceTransform =
//            workspaceTransformManager.transform()
//        
//        let pixelate = 
//            workspaceTransform.scale >
//            scalePixelateThreshold
//        
//        let viewportSize = Size(
//            metalView.bounds.width,
//            metalView.bounds.height)
//        
//        let commandBuffer = MetalInterface.shared
//            .commandQueue.makeCommandBuffer()!
//        
//        workspaceRenderer.draw(
//            target: drawable.texture,
//            commandBuffer: commandBuffer,
//            viewportSize: viewportSize,
//            workspaceTransform: workspaceTransform,
//            scene: scene, 
//            pixelate: pixelate)
//        
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
    
}

// MARK: - Delegates

extension TestEditorWorkspaceVC: CAMetalDisplayLinkDelegate {
    
    func metalDisplayLink(
        _ link: CAMetalDisplayLink,
        needsUpdate update: CAMetalDisplayLink.Update
    ) {
        workspaceTransformManager.onFrame()
        
        let viewportSize = Size(
            metalView.bounds.width,
            metalView.bounds.height)
        
        let workspaceTransform =
            workspaceTransformManager.transform()
        
        delegate?.onFrame(self,
            drawable: update.drawable,
            viewportSize: viewportSize,
            workspaceTransform: workspaceTransform)
    }
    
}

extension TestEditorWorkspaceVC: TestWorkspaceTransformManagerDelegate {
    
    func onUpdateTransform(
        _ m: TestWorkspaceTransformManager
    ) { 
        // TODO: Report to delegate that we need draw?
    }
    
}

extension TestEditorWorkspaceVC: TestWorkspaceMetalViewDelegate {
    
    func onRequestDraw(_ view: TestWorkspaceMetalView) {
        // TODO: Report to delegate that we need draw?
    }
    
}

extension TestEditorWorkspaceVC: TestWorkspaceOverlayViewDelegate {
    
    func onBeginWorkspaceTransformGesture(
        _ v: TestWorkspaceOverlayView
    ) {
        workspaceTransformManager.handleBeginTransformGesture()
    }
    
    func onUpdateWorkspaceTransformGesture(
        _ v: TestWorkspaceOverlayView,
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
        _ v: TestWorkspaceOverlayView,
        finalAnchorPosition: Vector,
        pinchFlickIn: Bool
    ) {
        workspaceTransformManager.handleEndTransformGesture(
            finalAnchorPosition: finalAnchorPosition,
            pinchFlickIn: pinchFlickIn)
    }
    
    func onSelectUndo(_ v: TestWorkspaceOverlayView) {
        delegate?.onSelectUndo(self)
    }
    
    func onSelectRedo(_ v: TestWorkspaceOverlayView) {
        delegate?.onSelectRedo(self)
    }
    
}
    
//    func onBeginBrushStroke(
//        _ vc: TestWorkspaceOverlayVC,
//        quickTap: Bool
//    ) {
//        brushEngine.beginStroke(
//            brush: brush,
//            color: .brushBlack,
//            scale: 0.05,
//            smoothing: 0,
//            quickTap: quickTap)
//    }
//    
//    func onUpdateBrushStroke(
//        _ vc: TestWorkspaceOverlayVC,
//        stroke: BrushGestureRecognizer.Stroke
//    ) {
//        let workspaceTransform =
//            workspaceTransformManager.transform()
//        
//        let workspaceViewSize = Size(
//            metalView.bounds.width,
//            metalView.bounds.height)
//        
//        let layerContentSize = Size(
//            Double(layerContentSize.width),
//            Double(layerContentSize.height))
//        
//        let inputStroke = TestBrushStrokeAdapter.convert(
//            stroke: stroke,
//            workspaceViewSize: workspaceViewSize,
//            workspaceTransform: workspaceTransform,
//            layerContentSize: layerContentSize,
//            layerTransform: layerTransform)
//        
//        brushEngine.updateStroke(inputStroke: inputStroke)
//    }
//    
//    func onEndBrushStroke(
//        _ vc: TestWorkspaceOverlayVC
//    ) {
//        brushEngine.endStroke()
//    }
//    
//    func onCancelBrushStroke(
//        _ vc: TestWorkspaceOverlayVC
//    ) {
//        brushEngine.cancelStroke()
//    }

//extension TestWorkspaceVC: BrushEngineDelegate {
//    
//    func onUpdateActiveCanvasTexture(
//        _ e: BrushEngine
//    ) { }
//    
//    func onFinalizeStroke(
//        _ e: BrushEngine,
//        canvasTexture: MTLTexture
//    ) { }
//    
//}
