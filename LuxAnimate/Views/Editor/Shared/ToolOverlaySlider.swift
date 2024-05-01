//
//  ToolOverlaySlider.swift
//

import UIKit

private let hPadding: CGFloat = 12
private let vPadding: CGFloat = 10

private let barWidth: CGFloat = 44
private let barHeight: CGFloat = 160

private let thumbInset: CGFloat = 5
private let thumbHeight: CGFloat = 16

private let shadowWidth: CGFloat = 1

private let scaleAnimDuration: TimeInterval = 0.3
private let scaleFactor: CGFloat = (barWidth + 4) / barWidth

private let dragRate: CGFloat = 1 / 300

protocol ToolOverlaySliderDelegate: AnyObject {
    
    func onBeginDrag(_ v: ToolOverlaySlider)
    func onEndDrag(_ v: ToolOverlaySlider)
    
    func onChangeValue(_ v: ToolOverlaySlider)
    
}

class ToolOverlaySlider: UIView {
    
    weak var delegate: ToolOverlaySliderDelegate?
    
    private let contentView = UIView()
    private let cardView = ToolOverlayCardView()
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
        thumbView.backgroundColor = UIColor(white: 0.8, alpha: 1)
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
                y: thumbPosition.rounded()),
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
            contentView.transform = CGAffineTransform(
                scaleX: scaleFactor,
                y: scaleFactor)
        }
    }
    
    private func showEndDrag() {
        UIView.animate(springDuration: scaleAnimDuration) {
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

private class ToolOverlayCardView: UIView {
    
    private let backgroundView = UIView()
    private let shadowView = UIView()
    
    var cornerRadius: CGFloat = 24 {
        didSet { updateCorners() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(shadowView)
        shadowView.backgroundColor = .white.withAlphaComponent(0.15)
        shadowView.layer.cornerCurve = .continuous
        
        addSubview(backgroundView)
        backgroundView.backgroundColor = .editorBar.withAlphaComponent(0.9)
        backgroundView.layer.cornerCurve = .continuous
        
        updateCorners()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = bounds
        
        shadowView.frame = bounds
            .insetBy(dx: -shadowWidth, dy: -shadowWidth)
    }
    
    private func updateCorners() {
        backgroundView.layer.cornerRadius = cornerRadius
        shadowView.layer.cornerRadius = cornerRadius + shadowWidth - 0.5
    }
    
}
