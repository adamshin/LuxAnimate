//
//  TimelineToolbarFrameWidgetScrubberCell.swift
//

import UIKit

class TimelineToolbarFrameWidgetScrubberCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tick = CircleView()
        tick.backgroundColor = UIColor(white: 1, alpha: 0.35)
        tick.layer.cornerCurve = .continuous
        addSubview(tick)
        tick.pinCenter()
        tick.pinWidth(to: 6)
        tick.pinHeight(to: 20)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
