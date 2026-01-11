//
//  AnimEditorTimelineTrackCell.swift
//

import UIKit

private let cellCornerRadius: CGFloat = 8
private let cellBorderColor = UIColor(white: 1, alpha: 0.1)

private let canvasBackgroundColor: UIColor = .white
private let noDrawingImageAlpha: CGFloat = 0.2

private let longPressDuration: TimeInterval = 0.5

private let buttonSelectAnimateInDuration: CGFloat = 0.1
private let buttonSelectAnimateOutDuration: CGFloat = 0.25
private let buttonSelectAnimateAlpha: CGFloat = 0.75
private let buttonSelectAnimateScale: CGFloat = (64 - 6) / 64

private let plusIconColor = UIColor(white: 1, alpha: 0.75)

private let plusIconAnimateScale: CGFloat = 0.3
private let plusIconAnimateInDuration: CGFloat = 0.3
private let plusIconAnimateInBounce: CGFloat = 0.4
private let plusIconAnimateOutDuration: CGFloat = 0.3
private let plusIconAnimateOutBounce: CGFloat = 0.4

private let plusIconConfig = UIImage.SymbolConfiguration(
    pointSize: 26,
    weight: .bold,
    scale: .medium)

private let plusIcon = UIImage(
    systemName: "plus.circle.fill",
    withConfiguration: plusIconConfig)

// MARK: - TimelineTrackCell

extension AnimEditorTimelineTrackCell {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onSelect(_ cell: AnimEditorTimelineTrackCell)
        func onLongPress(_ cell: AnimEditorTimelineTrackCell)
        
        func assetData(
            _ cell: AnimEditorTimelineTrackCell,
            assetID: String
        ) -> Data?
        
    }
    
}

class AnimEditorTimelineTrackCell: UICollectionViewCell {
    
    weak var delegate: Delegate?
    
    private let button = CellButton()
    private let cardView = CellCardView()
    private let imageView = UIImageView()
    private let plusIconView = CellPlusIconView()
    
    private let longPress = UILongPressGestureRecognizer()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addGestureRecognizer(longPress)
        longPress.minimumPressDuration = longPressDuration
        longPress.addTarget(self, action: #selector(onLongPress))
        
        contentView.addSubview(button)
        button.pinEdges()
        button.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelect(self)
        }
        
        button.addSubview(cardView)
        cardView.pinEdges()
        cardView.isUserInteractionEnabled = false
        
        cardView.addSubview(imageView)
        imageView.pinEdges()
        imageView.contentMode = .scaleAspectFill
        
        cardView.addSubview(plusIconView)
        plusIconView.pinEdges()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setPlusIconVisible(false, withAnimation: false)
        button.reset()
    }
    
    // MARK: - Handlers
    
    @objc private func onLongPress() {
        if longPress.state == .began {
            delegate?.onLongPress(self)
        }
    }
    
    // MARK: - Interface
    
    func updateContent(
        frame: AnimEditorTimelineViewModel.Frame
    ) {
        if frame.hasDrawing {
            imageView.backgroundColor = canvasBackgroundColor
            imageView.alpha = 1
        } else {
            imageView.backgroundColor = canvasBackgroundColor
            imageView.alpha = noDrawingImageAlpha
        }
        
        if let assetID = frame.assetID {
            let assetData = delegate?.assetData(
                self, assetID: assetID)
            imageView.image = UIImage(data: assetData ?? Data())
        } else {
            imageView.image = nil
        }
    }
    
    func setPlusIconVisible(
        _ visible: Bool,
        withAnimation: Bool
    ) {
        plusIconView.setIconVisible(
            visible,
            withAnimation: withAnimation)
    }
    
}

// MARK: - Button

private class CellButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                showHighlightAnimation()
            } else {
                showUnHighlightAnimation()
            }
        }
    }
    
    func reset() {
        layer.removeAllAnimations()
        alpha = 1
        transform = .identity
    }
    
    private func showHighlightAnimation() {
        UIView.animate(
            springDuration: buttonSelectAnimateInDuration,
            options: [.allowUserInteraction]
        ) {
            alpha = buttonSelectAnimateAlpha
            transform = CGAffineTransform(
                scaleX: buttonSelectAnimateScale,
                y: buttonSelectAnimateScale)
        }
    }
    
    private func showUnHighlightAnimation() {
        alpha = buttonSelectAnimateAlpha
        
        UIView.animate(
            springDuration: buttonSelectAnimateOutDuration,
            options: [.allowUserInteraction]
        ) {
            alpha = 1
            transform = .identity
        }
    }
    
}

// MARK: - Card

private class CellCardView: UIView {
    
    init() {
        super.init(frame: .zero)
        
        layer.masksToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = cellCornerRadius
        layer.borderWidth = 1.0
        layer.borderColor = cellBorderColor.cgColor
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}

// MARK: - Plus Icon

class CellPlusIconView: UIView {
    
    private let imageView = UIImageView(image: plusIcon)
    
    private var isIconVisible = true
    private var isIconVisibleDelayed = true
    
    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        
        addSubview(imageView)
        imageView.pinEdges()
        imageView.contentMode = .center
        imageView.tintColor = plusIconColor
        imageView.layer.shouldRasterize = true
        imageView.layer.rasterizationScale = UIScreen.main.scale
        
        setIconVisible(false, withAnimation: false)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setIconVisible(
        _ visible: Bool,
        withAnimation: Bool
    ) {
        if withAnimation {
            isIconVisible = visible
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                if self.isIconVisibleDelayed != self.isIconVisible {
                    self.isIconVisibleDelayed = self.isIconVisible
                    
                    if self.isIconVisible {
                        self.showPlusIconAppearAnimation()
                    } else {
                        self.showPlusIconDisappearAnimation()
                    }
                }
            }
            
        } else {
            isIconVisible = visible
            isIconVisibleDelayed = visible
            
            imageView.alpha = visible ? 1 : 0
            imageView.transform = .identity
        }
    }

    private func showPlusIconAppearAnimation() {
        imageView.alpha = 0
        imageView.transform = CGAffineTransform(
            scaleX: plusIconAnimateScale,
            y: plusIconAnimateScale)
        
        UIView.animate(
            springDuration: plusIconAnimateInDuration,
            bounce: plusIconAnimateInBounce)
        {
            imageView.alpha = 1
            imageView.transform = .identity
        }
    }
    
    private func showPlusIconDisappearAnimation() {
        imageView.alpha = 1
        imageView.transform = .identity
        
        UIView.animate(
            springDuration: plusIconAnimateOutDuration,
            bounce: plusIconAnimateOutBounce)
        {
            imageView.alpha = 0
            imageView.transform = CGAffineTransform(
                scaleX: plusIconAnimateScale,
                y: plusIconAnimateScale)
        }
    }
    
}
