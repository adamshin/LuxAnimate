//
//  EditorSidebarButton.swift
//

import UIKit

private let size: CGFloat = 44
private let hPadding: CGFloat = 12
private let vPadding: CGFloat = 6

private let iconConfig = UIImage.SymbolConfiguration(
    pointSize: 22,
    weight: .medium,
    scale: .medium)

private let icon = UIImage(
    systemName: "circle",
    withConfiguration: iconConfig)

class EditorSidebarButton: UIView {
    
    private let cardView = EditorSidebarCardView()
    private let imageView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(cardView)
        cardView.pinSize(to: size)
        cardView.pinEdges(.horizontal, padding: hPadding)
        cardView.pinEdges(.vertical, padding: vPadding)
        cardView.cornerRadius = 13
        
        let tickWidth: CGFloat = 18
        let tickHeight: CGFloat = 3
        let tickOffset: CGFloat = 4
        let tickColor = UIColor(white: 1, alpha: 0.7)
        
        let tick1 = CircleView()
        tick1.backgroundColor = tickColor
        cardView.addSubview(tick1)
        tick1.pinWidth(to: tickWidth)
        tick1.pinHeight(to: tickHeight)
        tick1.pin(.centerX)
        tick1.pin(.centerY, constant: -tickOffset)
        
        let tick2 = CircleView()
        tick2.backgroundColor = tickColor
        cardView.addSubview(tick2)
        tick2.pinWidth(to: tickWidth)
        tick2.pinHeight(to: tickHeight)
        tick2.pin(.centerX)
        tick2.pin(.centerY, constant: tickOffset)
        
//        addSubview(imageView)
//        imageView.pinEdges()
//        imageView.contentMode = .center
//        imageView.image = icon
//        imageView.tintColor = UIColor(white: 1, alpha: 0.7)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
