//
//  EditorMenuCardView.swift
//

import UIKit

private let outlineWidth: CGFloat = 1

private let overlayColor = UIColor.editorMenuOverlay

class EditorMenuCardView: UIView {
    
    private let blurView = ChromeBlurView(
        overlayColor: overlayColor)
    
    private let outlineView = UIView()
    
    private let shadowLayer1 = CALayer()
    
    var cornerRadius: CGFloat = 20 {
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
        
        layer.addSublayer(shadowLayer1)
        shadowLayer1.zPosition = -2
        shadowLayer1.shadowColor = UIColor.black.cgColor
        shadowLayer1.shadowOpacity = 0.25
        shadowLayer1.shadowRadius = 40
        shadowLayer1.shadowOffset.height = 20
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurView.layer.cornerRadius = cornerRadius
        outlineView.layer.cornerRadius = cornerRadius + outlineWidth
        
        let shadowMask = CGPath(roundedRect: bounds,
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil)
        
        shadowLayer1.frame = bounds
        shadowLayer1.shadowPath = shadowMask
    }
    
    var contentView: UIView {
        blurView.contentView
    }
    
}
