//
//  AnimEditorWorkspaceVC.swift
//

import UIKit
import Metal

private let minZoomScale: Scalar = 0.1
private let maxZoomScale: Scalar = 30

protocol AnimEditorWorkspaceVCDelegate: AnyObject {
    
    func onFrame(
        _ vc: AnimEditorWorkspaceVC,
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: AnimWorkspaceTransform)
    
    func onSelectUndo(_ vc: AnimEditorWorkspaceVC)
    func onSelectRedo(_ vc: AnimEditorWorkspaceVC)
    
}

class AnimEditorWorkspaceVC: UIViewController {
    
    weak var delegate: AnimEditorWorkspaceVCDelegate?
    
    private let metalView = AnimWorkspaceMetalView()
    private let overlayView = AnimWorkspaceOverlayView()
    
    private let workspaceTransformManager = AnimWorkspaceTransformManager()
    
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
    
    func workspaceTransform() -> AnimWorkspaceTransform {
        workspaceTransformManager.transform()
    }
    
}

// MARK: - Delegates

extension AnimEditorWorkspaceVC: CAMetalDisplayLinkDelegate {
    
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

extension AnimEditorWorkspaceVC: AnimWorkspaceTransformManagerDelegate {
    
    func onUpdateTransform(
        _ m: AnimWorkspaceTransformManager
    ) { 
        // TODO: Report to delegate that we need draw?
    }
    
}

extension AnimEditorWorkspaceVC: AnimWorkspaceMetalViewDelegate {
    
    func onRequestDraw(_ view: AnimWorkspaceMetalView) {
        // TODO: Report to delegate that we need draw?
    }
    
}

extension AnimEditorWorkspaceVC: AnimWorkspaceOverlayViewDelegate {
    
    func onBeginWorkspaceTransformGesture(
        _ v: AnimWorkspaceOverlayView
    ) {
        workspaceTransformManager.handleBeginTransformGesture()
    }
    
    func onUpdateWorkspaceTransformGesture(
        _ v: AnimWorkspaceOverlayView,
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
        _ v: AnimWorkspaceOverlayView,
        finalAnchorPosition: Vector,
        pinchFlickIn: Bool
    ) {
        workspaceTransformManager.handleEndTransformGesture(
            finalAnchorPosition: finalAnchorPosition,
            pinchFlickIn: pinchFlickIn)
    }
    
    func onSelectUndo(_ v: AnimWorkspaceOverlayView) {
        delegate?.onSelectUndo(self)
    }
    
    func onSelectRedo(_ v: AnimWorkspaceOverlayView) {
        delegate?.onSelectRedo(self)
    }
    
}
