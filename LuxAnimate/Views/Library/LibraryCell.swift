//
//  LibraryCell.swift
//

import UIKit

class LibraryCell: UICollectionViewCell {
    
    private let cardView = UIView()
    private let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        addSubview(stack)
        
        let cardContainer = UIView()
        stack.addArrangedSubview(cardContainer)
        stack.pinEdges(.horizontal)
        stack.pinEdges(.vertical, padding: 24)
        
        cardContainer.addSubview(cardView)
        cardView.pin(.centerX)
        cardView.pinEdges(.vertical)
        cardView.pinAspectRatio(to: 1)
        
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.cornerCurve = .continuous
        
        let labelContainer = UIView()
        stack.addArrangedSubview(labelContainer)
        labelContainer.pinHeight(to: 40)
        
        labelContainer.addSubview(nameLabel)
        nameLabel.pinEdges(.top)
        nameLabel.pin(.centerX)
        nameLabel.pin(.leading, constant: 20, priority: .defaultHigh)
        nameLabel.widthAnchor.constraint(
            lessThanOrEqualToConstant: 200).isActive = true
        
//        nameLabel.pinEdges(.horizontal, padding: 20)
        
        nameLabel.numberOfLines = 2
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(item: LibraryContentVC.Item) {
        setName(item.project.name)
    }
    
    private func setName(_ name: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 4
        
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
            .foregroundColor: UIColor.editorLabel,
        ]
        
        nameLabel.attributedText = NSAttributedString(
            string: name,
            attributes: attributes)
    }
    
}
