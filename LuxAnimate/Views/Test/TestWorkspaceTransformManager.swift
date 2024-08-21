//
//  TestWorkspaceTransformManager.swift
//

import Foundation

private let contentFitInset: CGFloat = 0

private let rotationSnapThreshold: Scalar =
    //8 * .radiansPerDegree
    20 * .radiansPerDegree

private let animationDuration: TimeInterval = 0.5

protocol TestWorkspaceTransformManagerDelegate: AnyObject {
    
    func onUpdateTransform(
        _ m: TestWorkspaceTransformManager)
    
}

class TestWorkspaceTransformManager {
    
    struct SafeAreaInsets {
        var top, bottom, left, right: Double
        
        static var zero = SafeAreaInsets(
            top: 0, bottom: 0,
            left: 0, right: 0)
    }
    
    struct Animation {
        var startTransform: TestWorkspaceTransform
        var endTransform: TestWorkspaceTransform
        
        var startTime: TimeInterval
        var endTime: TimeInterval
    }
    
    weak var delegate: TestWorkspaceTransformManagerDelegate?
    
    private var baseTransform: TestWorkspaceTransform = .identity
    private var activeGestureTransform: TestWorkspaceTransform?
    
    private var activeAnimation: Animation?
    
    private var viewportSize: Size = .zero
    private var viewportSafeAreaInsets: SafeAreaInsets = .zero
    
    private var contentSize: Size = .zero
    
    private var minScale: Double = 1
    private var maxScale: Double = 1
    
    private var isContentFitToViewport = false
    
    // MARK: - Transform
    
    private func handleUpdateWorkspaceParams() {
        activeGestureTransform = nil
        activeAnimation = nil
        
        if isContentFitToViewport {
            fitContentToViewport()
        }
    }
    
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
    
    private func transformSnapped(
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
    
    // MARK: - Animation
    
    private func animateTransform(
        startTransform: TestWorkspaceTransform,
        endTransform: TestWorkspaceTransform,
        duration: TimeInterval
    ) {
        let now = Date().timeIntervalSince1970
        
        activeAnimation = Animation(
            startTransform: startTransform,
            endTransform: endTransform,
            startTime: now,
            endTime: now + duration)
        
        self.activeGestureTransform = nil
        baseTransform = endTransform
        
        delegate?.onUpdateTransform(self)
    }
    
    private func updateActiveAnimationTransform() {
        guard let animation = activeAnimation else { return }
        
        let time = Date().timeIntervalSince1970
        
        if time > animation.endTime {
            baseTransform = animation.endTransform
            activeAnimation = nil
            delegate?.onUpdateTransform(self)
            
        } else {
            let transform = Self.transformForAnimation(
                animation: animation,
                time: time)
            
            baseTransform = transform
            delegate?.onUpdateTransform(self)
        }
    }
    
    private static func transformForAnimation(
        animation: Animation,
        time: TimeInterval
    ) -> TestWorkspaceTransform {
        
        let v: Double = map(time,
            in: (animation.startTime, animation.endTime),
            to: (0, 1))
        
        let c1 = 1 - v
        let c2 = v
        
        let translation =
            (c1 * animation.startTransform.translation) +
            (c2 * animation.endTransform.translation)
        
        let rotation = Self.interpolateRotation(
            start: animation.startTransform.rotation,
            end: animation.endTransform.rotation,
            t: v)
        
        let scale =
            (c1 * animation.startTransform.scale) +
            (c2 * animation.endTransform.scale)
        
        return TestWorkspaceTransform(
            translation: translation,
            rotation: rotation,
            scale: scale)
    }
    
    private static func interpolateRotation(
        start: Double, end: Double, t: Double
    ) -> Double {
        let start = start.truncatingRemainder(dividingBy: .twoPi)
        let end = end.truncatingRemainder(dividingBy: .twoPi)
        
        var diff = end - start
        if diff > .pi {
            diff -= .twoPi
        } else if diff < -.pi {
            diff += .twoPi
        }
        
        return (start + diff * t).truncatingRemainder(dividingBy: .twoPi)
    }
    
    // MARK: - Interface
    
    func onFrame() {
        updateActiveAnimationTransform()
    }
    
    func transform() -> TestWorkspaceTransform {
        if let activeGestureTransform {
            return activeGestureTransform
        } else {
            return baseTransform
        }
    }
    
    func setViewportSize(_ viewportSize: Size) {
        self.viewportSize = viewportSize
        handleUpdateWorkspaceParams()
    }
    
    func setViewportSafeAreaInsets(_ viewportSafeAreaInsets: SafeAreaInsets) {
        self.viewportSafeAreaInsets = viewportSafeAreaInsets
        handleUpdateWorkspaceParams()
    }
    
    func setContentSize(_ contentSize: Size) {
        self.contentSize = contentSize
        handleUpdateWorkspaceParams()
    }
    
    func setMinScale(_ minScale: Double) {
        self.minScale = minScale
    }
    
    func setMaxScale(_ maxScale: Double) {
        self.maxScale = maxScale
    }
    
    func fitContentToViewport() {
        isContentFitToViewport = true
        
        baseTransform = transformFittingContentToViewport()
        delegate?.onUpdateTransform(self)
    }
    
    func handleBeginTransformGesture() {
        isContentFitToViewport = false
        
        activeAnimation = nil
        activeGestureTransform = baseTransform
    }
    
    func handleUpdateTransformGesture(
        anchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        guard activeGestureTransform != nil
        else { return }
        
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
        delegate?.onUpdateTransform(self)
    }
    
    func handleEndTransformGesture(
        pinchFlickIn: Bool
    ) {
        guard let activeGestureTransform else { return }
        
        let endTransform: TestWorkspaceTransform
        if pinchFlickIn {
            isContentFitToViewport = true
            endTransform = transformFittingContentToViewport()
        } else {
            endTransform = transformSnapped(activeGestureTransform)
        }
        
        animateTransform(
            startTransform: activeGestureTransform,
            endTransform: endTransform,
            duration: animationDuration)
    }
    
}
