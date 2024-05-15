//
//  EditorSidebarButton.swift
//

import UIKit

private let size: CGFloat = 44
private let hPadding: CGFloat = 12
private let vPadding: CGFloat = 6

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
        
        addSubview(imageView)
        imageView.pinEdges()
        imageView.contentMode = .center
        imageView.tintColor = UIColor(white: 1, alpha: 0.7)
        imageView.image = .jogOutline
        
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
