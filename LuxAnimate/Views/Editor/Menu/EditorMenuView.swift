//
//  EditorMenuView.swift
//

import UIKit

private let defaultSpacing: CGFloat = 16

class EditorMenuContentView: UIView {
    weak var menuView: EditorMenuView?
}

protocol EditorMenuViewDelegate: AnyObject {
    func onPresent(_ v: EditorMenuView)
    func onDismiss(_ v: EditorMenuView)
}

struct EditorMenuPresentation {
    
    enum SourceViewEffect {
        case none
        case fade
    }
    
    enum Position {
        case top
    }
    
    var sourceView: UIView
    var sourceViewEffect: SourceViewEffect = .none
    var position: Position = .top
    var spacing: CGFloat = defaultSpacing
    
}

class EditorMenuView: PassthroughView {
    
    weak var delegate: EditorMenuViewDelegate?
    
    private let positioningView = EditorMenuPositioningView()
    private let animatorView = EditorMenuAnimatorView()
    private let cardView = EditorMenuCardView()
    
    private let dismissGesture = EditorMenuDismissGestureRecognizer()
    
    private var presentation: EditorMenuPresentation
    private var isDismissing = false
    
    // MARK: - Init
    
    init(
        contentView: EditorMenuContentView,
        presentation: EditorMenuPresentation
    ) {
        self.presentation = presentation
        super.init(frame: .zero)
        
        addSubview(positioningView)
        positioningView.pinEdges()
        
        positioningView.setContentView(animatorView)
        
        animatorView.addSubview(cardView)
        cardView.pinEdges()
        
        cardView.contentView.addSubview(contentView)
        contentView.pinEdges()
        contentView.menuView = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Present / Dismiss
    
    func present(in vc: UIViewController) {
        guard superview == nil else { return }
        guard let window = vc.view.window else { return }
        
        window.addGestureRecognizer(dismissGesture)
        dismissGesture.delegate = self
        dismissGesture.gestureDelegate = self
        
        window.addSubview(self)
        pinEdges()
        
        positioningView.setupConstraints(
            presentation: presentation)
        
        animatorView.showPresentAnimation(
            presentation: presentation)
        
        delegate?.onPresent(self)
    }
    
    func dismiss(animated: Bool = true) {
        guard !isDismissing else { return }
        isDismissing = true
        
        isUserInteractionEnabled = false
        
        dismissGesture.view?
            .removeGestureRecognizer(dismissGesture)
        
        if animated {
            animatorView.showDismissAnimation(
                presentation: presentation)
            {
                self.removeFromSuperview()
            }
        } else {
            removeFromSuperview()
        }
        
        delegate?.onDismiss(self)
    }
    
}

// MARK: - Delegates

extension EditorMenuView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        
        let loc = touch.location(in: cardView)
        return !cardView.bounds.contains(loc)
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith 
        otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        
        if otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
    
}

extension EditorMenuView: EditorMenuDismissGestureRecognizerDelegate {
    
    func onDismiss(
        _ gesture: EditorMenuDismissGestureRecognizer
    ) {
        dismiss()
    }
    
}

