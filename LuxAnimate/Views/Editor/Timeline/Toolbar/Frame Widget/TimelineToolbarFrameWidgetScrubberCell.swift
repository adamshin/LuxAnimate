//
//  TimelineToolbarFrameWidgetScrubberCell.swift
//

import UIKit

class TimelineToolbarFrameWidgetScrubberCell: UICollectionViewCell {
    
    let tick = CircleView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tick.backgroundColor = UIColor(white: 1, alpha: 0.35)
        tick.layer.cornerCurve = .continuous
        addSubview(tick)
        tick.pinCenter()
        tick.pinWidth(to: 6)
        tick.pinHeight(to: 20)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
