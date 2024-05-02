//
//  ToolOverlaySlider.swift
//

import UIKit

private let hPadding: CGFloat = 12
private let vPadding: CGFloat = 10

private let barWidth: CGFloat = 44
private let barHeight: CGFloat = 156

private let thumbInset: CGFloat = 5
private let thumbHeight: CGFloat = 16

private let outlineWidth: CGFloat = 1.0

private let scaleAnimDuration: TimeInterval = 0.25
private let scaleFactor: CGFloat = (barWidth + 4) / barWidth

private let thumbNormalColor = UIColor.white.withAlphaComponent(0.7)
private let thumbSelectedColor = UIColor.white.withAlphaComponent(0.95)

private let dragRate: CGFloat = 1 / 250

protocol ToolOverlaySliderDelegate: AnyObject {
    
    func onBeginDrag(_ v: ToolOverlaySlider)
    func onEndDrag(_ v: ToolOverlaySlider)
    
    func onChangeValue(_ v: ToolOverlaySlider)
    
}

class ToolOverlaySlider: UIView {
    
    weak var delegate: ToolOverlaySliderDelegate?
    
    private let contentView = UIView()
    private let cardView = ToolOverlaySliderCardView()
    private let thumbView = CircleView()
    
    private let panGesture = UILongPressGestureRecognizer()
    private var panGestureStartPosition: CGPoint?
    private var panGestureStartValue: Double?
    
    private var internalValue: Double = 0
    
    init() {
        super.init(frame: .zero)
        
        pinWidth(to: barWidth + hPadding * 2)
        pinHeight(to: barHeight + vPadding * 2)
        
        addSubview(contentView)
        contentView.isUserInteractionEnabled = false
        
        contentView.addSubview(cardView)
        cardView.cornerRadius = thumbInset + thumbHeight / 2
        
        contentView.addSubview(thumbView)
        thumbView.backgroundColor = thumbNormalColor
        thumbView.layer.cornerCurve = .continuous
        
        panGesture.minimumPressDuration = 0
        addGestureRecognizer(panGesture)
        panGesture.addTarget(self, action: #selector(onPan))
        
        value = 0
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.bounds = bounds
        contentView.center = bounds.center
        
        cardView.frame = CGRect(
            center: bounds.center,
            size: CGSize(width: barWidth, height: barHeight))
        
        let clampedValue = clamp(internalValue, min: 0, max: 1)
        
        let thumbRangeInset = thumbInset + thumbHeight / 2
        let thumbRangeStart = thumbRangeInset
        let thumbRangeEnd = barHeight - thumbRangeInset
        
        let thumbPosition =
            vPadding +
            thumbRangeStart +
            (1 - clampedValue) * (thumbRangeEnd - thumbRangeStart)
        
        thumbView.frame = CGRect(
            center: CGPoint(
                x: bounds.midX,
                y: thumbPosition),
            size: CGSize(
                width: barWidth - thumbInset * 2,
                height: thumbHeight))
    }
    
    @objc private func onPan() {
        switch panGesture.state {
        case .began:
            panGestureStartPosition = panGesture.location(in: self)
            panGestureStartValue = internalValue
            
            showBeginDrag()
            delegate?.onBeginDrag(self)
            
        case .changed:
            guard let panGestureStartPosition,
                let panGestureStartValue
            else { return }
            
            let newPosition = panGesture.location(in: self)
            let translationY = newPosition.y - panGestureStartPosition.y
            
            value = panGestureStartValue + (-translationY * dragRate)
            
        default:
            panGestureStartPosition = nil
            panGestureStartValue = nil
            
            showEndDrag()
            delegate?.onEndDrag(self)
        }
    }
    
    private func showBeginDrag() {
        UIView.animate(springDuration: scaleAnimDuration) {
            thumbView.backgroundColor = thumbSelectedColor
            
            contentView.transform = CGAffineTransform(
                scaleX: scaleFactor,
                y: scaleFactor)
        }
    }
    
    private func showEndDrag() {
        UIView.animate(springDuration: scaleAnimDuration) {
            thumbView.backgroundColor = thumbNormalColor
            
            contentView.transform = .identity
        }
    }
    
    var value: Double {
        get {
            internalValue
        }
        set {
            internalValue = clamp(newValue, min: 0, max: 1)
            setNeedsLayout()
        }
    }
    
}

class ToolOverlaySliderCardView: UIView {
    
    private let blurView = ChromeBlurView(
        overlayColor: .editorBarOverlay)
    
    private let outlineView = UIView()
    
    var cornerRadius: CGFloat = 24 {
        didSet { setNeedsLayout() }
    }
    
    init() {
        super.init(frame: .zero)
        
        addSubview(outlineView)
        outlineView.pinEdges(padding: -outlineWidth)
        outlineView.backgroundColor = .editorBarShadow
        outlineView.layer.cornerCurve = .continuous
        
        addSubview(blurView)
        blurView.pinEdges()
        blurView.layer.cornerCurve = .continuous
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurView.layer.cornerRadius = cornerRadius
        
        outlineView.layer.cornerRadius = cornerRadius + outlineWidth
    }
    
}
