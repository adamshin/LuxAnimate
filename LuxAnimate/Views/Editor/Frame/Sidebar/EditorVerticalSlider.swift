//
//  EditorVerticalSlider.swift
//

import UIKit

private let hPadding: CGFloat = 12
private let vPadding: CGFloat = 4

private let barWidth: CGFloat = 44
private let barHeight: CGFloat = 156

private let thumbInset: CGFloat = 5
private let thumbHeight: CGFloat = 16

private let pressAnimDuration: TimeInterval = 0.25
private let pressScaleFactor: CGFloat = 1//(barWidth + 4) / barWidth

private let thumbNormalColor = UIColor(white: 1, alpha: 0.7)
private let thumbSelectedColor = UIColor(white: 1, alpha: 0.95)

private let dragRate: CGFloat = 0.5

protocol EditorVerticalSliderDelegate: AnyObject {
    
    func onBeginPress(_ v: EditorVerticalSlider)
    func onEndPress(_ v: EditorVerticalSlider)
    
    func onChangeValue(_ v: EditorVerticalSlider)
    
}

// TODO: Rename this?
class EditorVerticalSlider: UIView {
    
    weak var delegate: EditorVerticalSliderDelegate?
    
    private let contentView = UIView()
    private let cardView = EditorSidebarCardView()
    private let thumbView = CircleView()
    
    private let pressGesture = UILongPressGestureRecognizer()
    private let panGesture = UIPanGestureRecognizer()
    private var panGestureStartValue: Double?
    
    private var internalValue: Double = 0
    
    // MARK: - Init
    
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
        
        addGestureRecognizer(pressGesture)
        pressGesture.addTarget(self, action: #selector(onPress))
        pressGesture.minimumPressDuration = 0
        
        addGestureRecognizer(panGesture)
        panGesture.addTarget(self, action: #selector(onPan))
        panGesture.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
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
    
    // MARK: - Handlers
    
    @objc private func onPress() {
        switch pressGesture.state {
        case .began: 
            showBeginPress()
            delegate?.onBeginPress(self)
            
        case .changed: 
            break
            
        default: 
            showEndPress()
            delegate?.onEndPress(self)
        }
    }
    
    @objc private func onPan() {
        switch panGesture.state {
        case .began:
            panGestureStartValue = internalValue
            
        case .changed:
            guard let panGestureStartValue
            else { return }
            
            let translation = panGesture.translation(in: self)
            
            let thumbRangeSize = barHeight -
                thumbHeight -
                thumbInset * 2
            
            let dv = -translation.y / thumbRangeSize * dragRate
            value = panGestureStartValue + dv
            
        default:
            panGestureStartValue = nil
        }
    }
    
    // MARK: - UI
    
    private func showBeginPress() {
        UIView.animate(springDuration: pressAnimDuration) {
            thumbView.backgroundColor = thumbSelectedColor
            
            contentView.transform = CGAffineTransform(
                scaleX: pressScaleFactor,
                y: pressScaleFactor)
        }
    }
    
    private func showEndPress() {
        UIView.animate(springDuration: pressAnimDuration) {
            thumbView.backgroundColor = thumbNormalColor
            contentView.transform = .identity
        }
    }
    
    // MARK: - Interface
    
    var value: Double {
        get {
            internalValue
        }
        set {
            internalValue = clamp(newValue, min: 0, max: 1)
            delegate?.onChangeValue(self)
            setNeedsLayout()
        }
    }
    
}

// MARK: - Delegates

extension EditorVerticalSlider: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith 
        otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return otherGestureRecognizer == pressGesture
    }
    
}
