//
//  TimelineTrackCell.swift
//

import UIKit

private let cornerRadiusFactor: CGFloat = 0.1

private let outlinePadding: CGFloat = 4
private let outlineWidth: CGFloat = 4

private let outlineColor: UIColor = .systemBlue

class TimelineTrackCell: UICollectionViewCell {
    
    private let cardView = TimelineTrackCardView()
    
    var hasDrawing: Bool = false {
        didSet { updateUI() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cardView.layer.cornerCurve = .continuous
        cardView.layer.borderColor = UIColor.editorBarShadow.withAlphaComponent(0.05).cgColor
        cardView.layer.borderWidth = 1.0
        
        contentView.addSubview(cardView)
        cardView.pinEdges()
        
        updateUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func updateUI() {
        if hasDrawing {
            cardView.backgroundColor = .white
        } else {
            cardView.backgroundColor = .white.withAlphaComponent(0.2)
        }
    }
    
}

class TimelineTrackCardView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 
            min(bounds.width, bounds.height) * cornerRadiusFactor
    }
    
}
