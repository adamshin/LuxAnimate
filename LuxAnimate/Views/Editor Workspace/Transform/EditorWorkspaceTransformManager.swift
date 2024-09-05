//
//  EditorWorkspaceTransformManager.swift
//

import Foundation

private let contentFitInset: CGFloat = 0

private let rotationSnapThreshold: Scalar =
    8 * .radiansPerDegree

private let shortSnapDuration: TimeInterval = 1.0
private let longSnapDuration: TimeInterval = 1.1

protocol EditorWorkspaceTransformManagerDelegate: AnyObject {
    
    func onUpdateTransform(
        _ m: EditorWorkspaceTransformManager)
    
}

class EditorWorkspaceTransformManager {
    
    struct SafeAreaInsets {
        var top, bottom, left, right: Double
        
        static var zero = SafeAreaInsets(
            top: 0, bottom: 0,
            left: 0, right: 0)
    }
    
    struct Animation {
        var startTransform: EditorWorkspaceTransform
        var endTransform: EditorWorkspaceTransform
        
        var startTime: TimeInterval
        var duration: TimeInterval
    }
    
    weak var delegate: EditorWorkspaceTransformManagerDelegate?
    
    private var baseTransform: EditorWorkspaceTransform = .identity
    private var activeGestureTransform: EditorWorkspaceTransform?
    
    private var activeAnimation: Animation?
    
    private var viewportSize: Size = .zero
    private var viewportSafeAreaInsets: SafeAreaInsets = .zero
    
    private var contentSize: Size = .zero
    
    private var minScale: Double = 1
    private var maxScale: Double = 1
    
    private var isContentFitToViewport = false
    
    // MARK: - Transform
    
    private func handleUpdateWorkspaceParams() {
        if isContentFitToViewport {
            fitContentToViewport()
        }
    }
    
    private func transformFittingContentToViewport()
    -> EditorWorkspaceTransform {
        
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
        
        return EditorWorkspaceTransform(
            translation: viewportSafeAreaCenterOffset,
            rotation: 0,
            scale: scale)
    }
    
    private func snapTransform(
        transform: EditorWorkspaceTransform,
        anchor: Vector
    ) -> EditorWorkspaceTransform {
        
        var snappedTransform = transform
        
        snappedTransform.snapScale(
            minScale: minScale,
            maxScale: maxScale,
            anchor: anchor)
        
        snappedTransform.snapRotation(
            threshold: rotationSnapThreshold,
            anchor: anchor)
        
//        snappedTransform.snapTranslationToKeepRectContainingOrigin(
//            x: -contentSize.width / 2,
//            y: -contentSize.height / 2,
//            width: contentSize.width,
//            height: contentSize.height)
        
        return snappedTransform
    }
    
    // MARK: - Animation
    
    private func animateTransform(
        startTransform: EditorWorkspaceTransform,
        endTransform: EditorWorkspaceTransform,
        duration: TimeInterval
    ) {
        let now = Date().timeIntervalSince1970
        
        activeAnimation = Animation(
            startTransform: startTransform,
            endTransform: endTransform,
            startTime: now,
            duration: duration)
        
        self.activeGestureTransform = nil
        baseTransform = endTransform
        
        delegate?.onUpdateTransform(self)
    }
    
    private func updateActiveAnimationTransform() {
        guard let animation = activeAnimation else { return }
        
        let time = Date().timeIntervalSince1970
        let endTime = animation.startTime + animation.duration
        
        if time > endTime {
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
    ) -> EditorWorkspaceTransform {
        
        let startTime = animation.startTime
        let endTime = startTime + animation.duration
        
        let t: Double = map(time,
            in: (startTime, endTime),
            to: (0, 1))
        
        let v = springInterpolate(
            t: t,
            duration: animation.duration)
        
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
        
        return EditorWorkspaceTransform(
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
    
    func transform() -> EditorWorkspaceTransform {
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
        initialAnchorPosition: Vector,
        translation: Vector,
        rotation: Scalar,
        scale: Scalar
    ) {
        guard activeGestureTransform != nil
        else { return }
        
        let anchor = Vector(
            initialAnchorPosition.x - viewportSize.width / 2,
            initialAnchorPosition.y - viewportSize.height / 2)
        
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
        finalAnchorPosition: Vector,
        pinchFlickIn: Bool
    ) {
        guard let activeGestureTransform else { return }
        
        let anchor = Vector(
            finalAnchorPosition.x - viewportSize.width / 2,
            finalAnchorPosition.y - viewportSize.height / 2)
        
        if pinchFlickIn {
            isContentFitToViewport = true
            
            let endTransform = transformFittingContentToViewport()
            
            animateTransform(
                startTransform: activeGestureTransform,
                endTransform: endTransform,
                duration: longSnapDuration)
            
        } else {
            let endTransform = snapTransform(
                transform: activeGestureTransform,
                anchor: anchor)
            
            animateTransform(
                startTransform: activeGestureTransform,
                endTransform: endTransform,
                duration: shortSnapDuration)
        }
    }
    
}

// MARK: - Spring

private func springInterpolate(
    t: Double,
    duration: Double
) -> Double {
    
    let a: Double = 1
    let b: Double = 20 / duration
    let g: Double = b
    
    let y = (a + b*t) * exp(-g * t)
    return 1 - y
}
