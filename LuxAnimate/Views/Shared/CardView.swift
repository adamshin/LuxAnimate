//
//  CardView.swift
//

import UIKit

class CardView: UIView {
    
    private let backgroundView = UIView()
    private let shadowView = UIView()
    
    var cornerRadius: CGFloat = 24 {
        didSet { updateCorners() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(shadowView)
        shadowView.backgroundColor = .editorBarShadow
        shadowView.layer.cornerCurve = .continuous
        
        addSubview(backgroundView)
        backgroundView.backgroundColor = .editorBar
        backgroundView.layer.cornerCurve = .continuous
        
        updateCorners()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = bounds
        
        shadowView.frame = bounds
            .insetBy(dx: -1, dy: -1)
    }
    
    private func updateCorners() {
        backgroundView.layer.cornerRadius = cornerRadius
        shadowView.layer.cornerRadius = cornerRadius + 1.5
    }
    
}
