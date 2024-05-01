//
//  EditorPopupMenuCardView.swift
//

import UIKit

private let outlineWidth: CGFloat = 1

class EditorPopupMenuCardView: UIView {
    
    private let blurEffect: UIBlurEffect
    private let vibrancyEffect: UIVibrancyEffect
    
    private let blurView: UIVisualEffectView
    private let vibrancyView: UIVisualEffectView
    
    private let outlineColorView = UIView()
    private let backgroundColorView = UIView()
    
    private let shadowLayer1 = CALayer()
    
    var cornerRadius: CGFloat = 24 {
        didSet { setNeedsLayout() }
    }
    
    override init(frame: CGRect) {
        blurEffect = UIBlurEffect(
            style: .systemThinMaterialDark)
        
        vibrancyEffect = UIVibrancyEffect(
            blurEffect: blurEffect,
            style: .fill)
        
        blurView = UIVisualEffectView(effect: blurEffect)
        vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        
        super.init(frame: frame)
        
        addSubview(blurView)
        blurView.pinEdges()
        blurView.layer.masksToBounds = true
        blurView.layer.cornerCurve = .continuous
        
        blurView.contentView.addSubview(vibrancyView)
        vibrancyView.pinEdges()
        
        vibrancyView.contentView.addSubview(outlineColorView)
        outlineColorView.pinEdges()
        outlineColorView.backgroundColor = .white.withAlphaComponent(0.2)
        
        blurView.contentView.addSubview(backgroundColorView)
        backgroundColorView.pinEdges(padding: outlineWidth)
        backgroundColorView.backgroundColor = .editorBackground.withAlphaComponent(0.5)
        backgroundColorView.layer.cornerCurve = .continuous
        
        layer.addSublayer(shadowLayer1)
        shadowLayer1.zPosition = -2
        shadowLayer1.shadowColor = UIColor.black.cgColor
        shadowLayer1.shadowOpacity = 0.3
        shadowLayer1.shadowRadius = 40
        shadowLayer1.shadowOffset.height = 20
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurView.layer.cornerRadius = cornerRadius
        backgroundColorView.layer.cornerRadius = cornerRadius - outlineWidth
        
        let shadowMask = CGPath(roundedRect: bounds,
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        shadowLayer1.frame = bounds
        shadowLayer1.shadowPath = shadowMask
        
        CATransaction.commit()
    }
    
}

