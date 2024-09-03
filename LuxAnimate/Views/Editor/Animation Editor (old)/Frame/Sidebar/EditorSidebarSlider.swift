//
//  EditorSidebarSlider.swift
//

import UIKit

private let hPadding: CGFloat = 12
private let vPadding: CGFloat = 10

private let barWidth: CGFloat = 44
private let barHeight: CGFloat = 152

private let thumbInset: CGFloat = 5
private let thumbHeight: CGFloat = 16

private let selectAnimDuration: TimeInterval = 0.25
private let selectedScale = (barWidth + 2) / barWidth

private let thumbNormalColor = UIColor(white: 1, alpha: 0.7)
private let thumbSelectedColor = UIColor.editorLabel

private let dragRate: CGFloat = 0.6

private let flickVelocityThreshold: CGFloat = 500
private let flickDecelDuration: TimeInterval = 0.2
private let flickDistanceMultiplier: CGFloat = 0.0005

protocol EditorSidebarSliderDelegate: AnyObject {
    
    func onBeginPress(_ v: EditorSidebarSlider)
    func onEndPress(_ v: EditorSidebarSlider)
    func onChangeValue(_ v: EditorSidebarSlider)
    
}

class EditorSidebarSlider: UIView {
    
    weak var delegate: EditorSidebarSliderDelegate?
    
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
        
        contentView.bounds = CGRect(
            origin: .zero,
            size: CGSize(
                width: barWidth,
                height: barHeight))
        
        contentView.center = bounds.center
        
        cardView.frame = contentView.bounds
        cardView.cornerRadius = thumbInset + thumbHeight / 2
        
        let clampedValue = clamp(internalValue, min: 0, max: 1)
        
        let thumbRangeInset = thumbInset + thumbHeight / 2
        let thumbRangeStart = thumbRangeInset
        let thumbRangeEnd = barHeight - thumbRangeInset
        
        let thumbPosition = map(
            clampedValue,
            in: (1, 0),
            to: (thumbRangeStart, thumbRangeEnd))
        
        thumbView.frame = CGRect(
            center: CGPoint(
                x: contentView.bounds.midX,
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
            guard let panGestureStartValue else { return }
            
            let translation = panGesture.translation(in: self)
            
            let thumbRangeSize = barHeight
                - thumbHeight
                - thumbInset * 2
            
            let dv = -translation.y / thumbRangeSize * dragRate
            value = panGestureStartValue + dv
            
        case .ended:
            panGestureStartValue = nil
            
            let velocity = panGesture.velocity(in: self)
            
            if abs(velocity.y) > flickVelocityThreshold {
                let finalValue = clamp(
                    value - velocity.y * flickDistanceMultiplier,
                    min: 0, max: 1)
                
                UIView.animate(springDuration: flickDecelDuration) {
                    self.value = finalValue
                    layoutIfNeeded()
                }
            }
            
        default:
            panGestureStartValue = nil
        }
    }
    
    // MARK: - UI
    
    private func showBeginPress() {
        UIView.animate(springDuration: selectAnimDuration) {
            contentView.transform = CGAffineTransform(
                scaleX: selectedScale,
                y: selectedScale)
            
            thumbView.backgroundColor = thumbSelectedColor
        }
    }
    
    private func showEndPress() {
        UIView.animate(springDuration: selectAnimDuration) {
            contentView.transform = .identity
            thumbView.backgroundColor = thumbNormalColor
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

extension EditorSidebarSlider: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith
        otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return otherGestureRecognizer == pressGesture
    }
    
}
