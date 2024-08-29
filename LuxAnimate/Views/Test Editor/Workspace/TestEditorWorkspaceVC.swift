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
    
    func addToolGestureRecognizer(_ g: UIGestureRecognizer) {
        overlayView.addToolGestureRecognizer(g)
    }
    
    func removeAllToolGestureRecognizers() {
        overlayView.removeAllToolGestureRecognizers()
    }
    
    func workspaceTransform() -> TestWorkspaceTransform {
        workspaceTransformManager.transform()
    }
    
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
