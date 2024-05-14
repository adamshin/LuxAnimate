//
//  ChromeBlurView.swift
//

import UIKit

class ChromeBlurView: UIVisualEffectView {
    
    private let overlayView = UIView()
    
    init(overlayColor: UIColor = .clear) {
        super.init(effect: UIBlurEffect(
            style: .systemThinMaterialDark))
        
        layer.masksToBounds = true
        contentView.addSubview(overlayView)
        
        overlayView.backgroundColor = overlayColor
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        overlayView.frame = contentView.bounds
    }
    
}
