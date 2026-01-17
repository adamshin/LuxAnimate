//
//  AnimEditorToolSidebarCardView.swift
//

import UIKit

private let outlineWidth: CGFloat = 1.0

class AnimEditorToolSidebarCardView: UIView {
    
    private let blurView = ChromeBlurView(
        overlayColor: .editorBarOverlay)
    
    private let outlineView = UIView()
    
    private let shadowLayer = CALayer()
    
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
        
        layer.addSublayer(shadowLayer)
        shadowLayer.zPosition = -2
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = 0.25
        shadowLayer.shadowRadius = 40
        shadowLayer.shadowOffset.height = 20
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurView.layer.cornerRadius = cornerRadius
        outlineView.layer.cornerRadius = cornerRadius + outlineWidth
        
        let shadowMask = CGPath(
            roundedRect: bounds,
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil)
        
        shadowLayer.frame = bounds
        shadowLayer.shadowPath = shadowMask
    }
    
    var contentView: UIView {
        blurView.contentView
    }
    
}
