//
//  EditorWorkspaceVC.swift
//

import UIKit
import Metal
import Geometry

private let minZoomScale: Double = 0.1
private let maxZoomScale: Double = 30

extension EditorWorkspaceVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        func onSelectUndo(_ vc: EditorWorkspaceVC)
        func onSelectRedo(_ vc: EditorWorkspaceVC)
    }
    
}

class EditorWorkspaceVC: UIViewController {
    
    weak var delegate: Delegate?
    
    private let metalView = EditorWorkspaceMetalView()
    private let overlayView = EditorWorkspaceOverlayView()
    
    private let transformManager =
        EditorWorkspaceTransformManager()
    
    private let renderer = EditorWorkspaceRenderer()
    
    private var sceneGraph: EditorWorkspaceSceneGraph?
    private var needsDraw = false
    
    private var safeAreaReferenceView: UIView?
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        transformManager.delegate = self
        transformManager.setMinScale(minZoomScale)
        transformManager.setMaxScale(maxZoomScale)
        transformManager.fitContentToViewport()
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
        
        transformManager.setViewportSize(Size(
            metalView.bounds.width,
            metalView.bounds.height))
        
        handleSafeAreaReferenceViewBoundsChange()
    }
    
    // MARK: - Render
    
    private func draw() {
        guard let sceneGraph else { return }
        
        guard let drawable =
            metalView.metalLayer.nextDrawable()
        else { return }
        
        let viewportSize = Size(
            metalView.bounds.width,
            metalView.bounds.height)
        
        let workspaceTransform =
            transformManager.transform()
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        renderer.draw(
            target: drawable.texture,
            commandBuffer: commandBuffer,
            viewportSize: viewportSize,
            workspaceTransform: workspaceTransform,
            sceneGraph: sceneGraph)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    // MARK: - Interface
    
    func setSceneGraph(
        _ sceneGraph: EditorWorkspaceSceneGraph
    ) {
        self.sceneGraph = sceneGraph
        
        transformManager.setContentSize(
            sceneGraph.contentSize)
        
        needsDraw = true
    }
    
    func onFrame() {
        // TODO: Check needsDraw?
        autoreleasepool {
            transformManager.onFrame()
            draw()
        }
    }
    
    func addOverlayGestureRecognizer(
        _ g: UIGestureRecognizer
    ) {
        overlayView.addOverlayGestureRecognizer(g)
    }
    
    func removeAllOverlayGestureRecognizers() {
        overlayView.removeAllOverlayGestureRecognizers()
    }
    
    func workspaceTransform() -> EditorWorkspaceTransform {
        transformManager.transform()
    }
    
    func setSafeAreaReferenceView(_ v: UIView) {
        safeAreaReferenceView = v
        handleSafeAreaReferenceViewBoundsChange()
    }
    
    func handleSafeAreaReferenceViewBoundsChange() {
        guard let safeAreaReferenceView else { return }
        
        let safeAreaFrame = safeAreaReferenceView.convert(
            safeAreaReferenceView.bounds,
            to: view)
        
        var insets = EditorWorkspaceTransformManager
            .SafeAreaInsets.zero
        
        insets.left = safeAreaFrame.minX
        insets.right = view.bounds.width - safeAreaFrame.maxX
        insets.top = safeAreaFrame.minY
        insets.bottom = view.bounds.height - safeAreaFrame.maxY
        
        transformManager.setViewportSafeAreaInsets(insets)
    }
    
}

// MARK: - Delegates

extension EditorWorkspaceVC:
    EditorWorkspaceMetalView.Delegate {
    
    func onRequestDraw(
        _ view: EditorWorkspaceMetalView
    ) {
        needsDraw = true
    }
    
}

extension EditorWorkspaceVC:
    EditorWorkspaceOverlayView.Delegate {
    
    func onBeginWorkspaceTransformGesture(
        _ v: EditorWorkspaceOverlayView
    ) {
        transformManager.handleBeginTransformGesture()
    }
    
    func onUpdateWorkspaceTransformGesture(
        _ v: EditorWorkspaceOverlayView,
        initialAnchorPosition: Vector,
        translation: Vector,
        rotation: Double,
        scale: Double
    ) {
        transformManager.handleUpdateTransformGesture(
            initialAnchorPosition: initialAnchorPosition,
            translation: translation,
            rotation: rotation,
            scale: scale)
    }
    
    func onEndWorkspaceTransformGesture(
        _ v: EditorWorkspaceOverlayView,
        finalAnchorPosition: Vector,
        pinchFlickIn: Bool
    ) {
        transformManager.handleEndTransformGesture(
            finalAnchorPosition: finalAnchorPosition,
            pinchFlickIn: pinchFlickIn)
    }
    
    func onSelectUndo(_ v: EditorWorkspaceOverlayView) {
        delegate?.onSelectUndo(self)
    }
    
    func onSelectRedo(_ v: EditorWorkspaceOverlayView) {
        delegate?.onSelectRedo(self)
    }
    
}

extension EditorWorkspaceVC:
    EditorWorkspaceTransformManager.Delegate {
    
    func onUpdateTransform(
        _ m: EditorWorkspaceTransformManager
    ) {
        needsDraw = true
    }
    
}
