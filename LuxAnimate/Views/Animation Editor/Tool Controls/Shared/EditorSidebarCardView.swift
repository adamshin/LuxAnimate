//
//  EditorSidebarCardView.swift
//

import UIKit

private let outlineWidth: CGFloat = 1.0

class EditorSidebarCardView: UIView {
    
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
