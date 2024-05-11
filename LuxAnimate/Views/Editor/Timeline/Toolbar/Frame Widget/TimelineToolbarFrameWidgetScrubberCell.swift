//
//  TimelineToolbarFrameWidgetScrubberCell.swift
//

import UIKit

class TimelineToolbarFrameWidgetScrubberCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tick = CircleView()
        tick.backgroundColor = .editorLabel
        addSubview(tick)
        tick.pinCenter()
        tick.pinSize(to: 8)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
