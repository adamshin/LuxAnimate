//
//  TestWorkspaceTransformManager.swift
//

import Foundation

private let contentFitInset: CGFloat = 0

private let rotationSnapThreshold: Scalar =
    8 * .radiansPerDegree

protocol TestWorkspaceTransformManagerDelegate: AnyObject {
    func onUpdateTransform(
        _ m: TestWorkspaceTransformManager,
        transform: TestWorkspaceTransform)
}

class TestWorkspaceTransformManager {
    
    struct SafeAreaInsets {
        var top, bottom, left, right: Double
        
        static var zero = SafeAreaInsets(
            top: 0, bottom: 0,
            left: 0, right: 0)
    }
    
    weak var delegate: TestWorkspaceTransformManagerDelegate?
    
    private var baseTransform = TestWorkspaceTransform.identity
    private var activeGestureTransform: TestWorkspaceTransform?
    
    private var viewportSize: Size = .zero
    private var viewportSafeAreaInsets: SafeAreaInsets = .zero
    
    private var contentSize: Size = .zero
    
    private var minScale: Double = 1
    private var maxScale: Double = 1
    
    private var isContentFitToViewport = false
    
    // MARK: - Transform
    
    private func transformFittingContentToViewport()
    -> TestWorkspaceTransform {
        
        guard contentSize.width > 0, contentSize.height > 0
        else { return .identity }
        
        let viewportSafeAreaCenterOffset = Vector(
            viewportSafeAreaInsets.left - viewportSafeAreaInsets.right,
            viewportSafeAreaInsets.top - viewportSafeAreaInsets.bottom)
            / 2
        
        let availableWidth = viewportSize.width
            - viewportSafeAreaInsets.left
            - viewportSafeAreaInsets.right
            - contentFitInset * 2
        let availableHeight = viewportSize.height
            - viewportSafeAreaInsets.top
            - viewportSafeAreaInsets.bottom
            - contentFitInset * 2
        
        let xScaleToFit = availableWidth / contentSize.width
        let yScaleToFit = availableHeight / contentSize.height
        
        let scale = min(xScaleToFit, yScaleToFit)
        
        return TestWorkspaceTransform(
            translation: viewportSafeAreaCenterOffset,
            rotation: 0,
            scale: scale)
    }
    
    private func transformSnapping(
        _ transform: TestWorkspaceTransform
    ) -> TestWorkspaceTransform {
        
        var snappedTransform = transform
        
        snappedTransform.snapScale(
            minScale: minScale,
            maxScale: maxScale)
        
        snappedTransform.snapRotation(
            threshold: rotationSnapThreshold)
        
//        snappedTransform.snapTranslationToKeepRectContainingOrigin(
//            x: -contentSize.width / 2,
//            y: -contentSize.height / 2,
//            width: contentSize.width,
//            height: contentSize.height)
        
        return snappedTransform
    }
    
    // MARK: - Interface
    
    func setViewportSize(_ viewportSize: Size) {
        self.viewportSize = viewportSize
    }
    
    func setViewportSafeAreaInsets(_ viewportSafeAreaInsets: SafeAreaInsets) {
        self.viewportSafeAreaInsets = viewportSafeAreaInsets
    }
    
    func setContentSize(_ contentSize: Size) {
        self.contentSize = contentSize
    }
    
    func setMinScale(_ minScale: Double) {
        self.minScale = minScale
    }
    
    func setMaxScale(_ maxScale: Double) {
        self.maxScale = maxScale
    }
    
    func handleBeginTransformGesture() {
        isContentFitToViewport = false
        activeGestureTransform = baseTransform
    }
    
    func handleUpdateTransformGesture(
        anchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        let anchor = Vector(
            anchorPosition.x - viewportSize.width / 2,
            anchorPosition.y - viewportSize.height / 2)
        
        var newTransform = baseTransform
        
        newTransform.applyScale(scale,
            minScale: 0,
            maxScale: maxScale,
            anchor: anchor)
        
        newTransform.applyRotation(rotation, anchor: anchor)
        
        newTransform.applyTranslation(translation)
        
        self.activeGestureTransform = newTransform
        
        delegate?.onUpdateTransform(self,
            transform: newTransform)
    }
    
    func handleEndTransformGesture(
        pinchFlickIn: Bool
    ) {
        guard let activeGestureTransform else { return }
        
        if pinchFlickIn {
            isContentFitToViewport = true
            
            self.activeGestureTransform = nil
            baseTransform = transformFittingContentToViewport()
            
            delegate?.onUpdateTransform(self,
                transform: baseTransform)
            
        } else {
            self.activeGestureTransform = nil
            baseTransform = transformSnapping(
                activeGestureTransform)
            
            delegate?.onUpdateTransform(self,
                transform: baseTransform)
        }
    }
    
}
