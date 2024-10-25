//
//  EditorWorkspaceVC.swift
//

import UIKit
import Metal
import Geometry

private let minZoomScale: Scalar = 0.1
private let maxZoomScale: Scalar = 30

@MainActor
protocol EditorWorkspaceVCDelegate: AnyObject {
    
    func onSelectUndo(_ vc: EditorWorkspaceVC)
    func onSelectRedo(_ vc: EditorWorkspaceVC)
    
}

class EditorWorkspaceVC: UIViewController {
    
    weak var delegate: EditorWorkspaceVCDelegate?
    
    let metalView = EditorWorkspaceMetalView()
    private let overlayView = EditorWorkspaceOverlayView()
    
    private let workspaceTransformManager = EditorWorkspaceTransformManager()
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
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
    
    func onFrame() {
        workspaceTransformManager.onFrame()
    }
    
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
    
    func viewportSize() -> Size {
        Size(
            metalView.bounds.width,
            metalView.bounds.height)
    }
    
    func workspaceTransform() -> EditorWorkspaceTransform {
        workspaceTransformManager.transform()
    }
    
}

// MARK: - Delegates

extension EditorWorkspaceVC: EditorWorkspaceTransformManagerDelegate {
    
    func onUpdateTransform(
        _ m: EditorWorkspaceTransformManager
    ) { 
        // TODO: Report to delegate that we need draw?
    }
    
}

extension EditorWorkspaceVC: EditorWorkspaceMetalViewDelegate {
    
    func onRequestDraw(_ view: EditorWorkspaceMetalView) {
        // TODO: Report to delegate that we need draw?
    }
    
}

extension EditorWorkspaceVC: EditorWorkspaceOverlayViewDelegate {
    
    func onBeginWorkspaceTransformGesture(
        _ v: EditorWorkspaceOverlayView
    ) {
        workspaceTransformManager.handleBeginTransformGesture()
    }
    
    func onUpdateWorkspaceTransformGesture(
        _ v: EditorWorkspaceOverlayView,
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
        _ v: EditorWorkspaceOverlayView,
        finalAnchorPosition: Vector,
        pinchFlickIn: Bool
    ) {
        workspaceTransformManager.handleEndTransformGesture(
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
