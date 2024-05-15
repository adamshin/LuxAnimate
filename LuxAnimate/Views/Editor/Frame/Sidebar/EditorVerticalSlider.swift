//
//  EditorVerticalSlider.swift
//

import UIKit

private let hPadding: CGFloat = 12
private let vPadding: CGFloat = 6

private let barWidth: CGFloat = 44
private let barHeight: CGFloat = 150

private let thumbInset: CGFloat = 5
private let thumbHeight: CGFloat = 16
private let selectedThumbHeight: CGFloat = 17

private let pressAnimDuration: TimeInterval = 0.25
private let selectedHPadding: CGFloat = 2
private let selectedVPadding: CGFloat = 4

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
    
    private var isExpanded = false {
        didSet { setNeedsLayout() }
    }
    
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
        
        let hPadding: CGFloat = isExpanded ?
            selectedHPadding : 0
        let vPadding: CGFloat = isExpanded ?
            selectedVPadding : 0
        
        let adjustedBarWidth = barWidth + hPadding * 2
        let adjustedBarHeight = barHeight + vPadding * 2
        
        let adjustedThumbHeight = isExpanded ?
            selectedThumbHeight : thumbHeight
        
        contentView.frame = CGRect(
            center: bounds.center,
            size: CGSize(
                width: adjustedBarWidth,
                height: adjustedBarHeight))
        
        cardView.frame = contentView.bounds
        cardView.cornerRadius = thumbInset + adjustedThumbHeight / 2
        
        let clampedValue = clamp(internalValue, min: 0, max: 1)
        
        let thumbRangeInset = thumbInset + adjustedThumbHeight / 2
        let thumbRangeStart = thumbRangeInset
        let thumbRangeEnd = adjustedBarHeight - thumbRangeInset
        
        let thumbPosition = map(
            clampedValue,
            in: (1, 0),
            to: (thumbRangeStart, thumbRangeEnd))
        
        thumbView.frame = CGRect(
            center: CGPoint(
                x: contentView.bounds.midX,
                y: thumbPosition),
            size: CGSize(
                width: adjustedBarWidth - thumbInset * 2,
                height: adjustedThumbHeight))
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
            isExpanded = true
            layoutIfNeeded()
        }
    }
    
    private func showEndPress() {
        UIView.animate(springDuration: pressAnimDuration) {
            thumbView.backgroundColor = thumbNormalColor
            isExpanded = false
            layoutIfNeeded()
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
