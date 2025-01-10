//
//  AnimEditorDrawerVC.swift
//

import UIKit

private let toolbarHeight: CGFloat = 48
private let separatorColor = UIColor(white: 1, alpha: 0.04)

private let animationDuration: TimeInterval = 0.25
private let animationBounce: TimeInterval = 0

@MainActor
protocol AnimEditorDrawerVCDelegate: AnyObject {
    
    func onSetExpanded(
        _ vc: AnimEditorDrawerVC,
        _ expanded: Bool)
    
    func onChangeDrawerSize(
        _ vc: AnimEditorDrawerVC)
    
}

class AnimEditorDrawerVC: UIViewController {
    
    weak var delegate: AnimEditorDrawerVCDelegate?
    
    let remainderContentView = PassthroughView()
    
    let drawerContentView = UIView()
    let toolbar = AnimEditorDrawerToolbar()
    let collapsibleContentView = UIView()
    
    private let bottomAreaContainer = UIView()
    private let separator = UIView()
    
    private let swipeGesture = AnimEditorDrawerSwipeGestureRecognizer()
    
    private var expandedConstraint: NSLayoutConstraint?
    private var collapsedConstraint: NSLayoutConstraint?
    
    private var isExpanded = false
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(remainderContentView)
        remainderContentView.pinEdges([.horizontal, .top])
        
        view.addSubview(drawerContentView)
        drawerContentView.pinEdges([.horizontal, .bottom])
        drawerContentView.pin(.top,
            to: remainderContentView,
            toAnchor: .bottom)
        
        let blurView = ChromeBlurView()
        drawerContentView.addSubview(blurView)
        blurView.pinEdges()
        blurView.backgroundColor = .editorBarShadow
        
        let stack = UIStackView()
        stack.axis = .vertical
        drawerContentView.addSubview(stack)
        stack.pinEdges()
        
        stack.addArrangedSubview(toolbar)
        
        let separatorContainer = UIView()
        separatorContainer.backgroundColor = .editorBarOverlay
        stack.addArrangedSubview(separatorContainer)
        separatorContainer.pinHeight(to: 1)
        
        separatorContainer.addSubview(separator)
        separator.pinEdges()
        
        stack.addArrangedSubview(bottomAreaContainer)
        bottomAreaContainer.addSubview(collapsibleContentView)
        collapsibleContentView.pinEdges([.horizontal, .top])
        
        expandedConstraint = collapsibleContentView
            .pinEdges(.bottom, to: view.safeAreaLayoutGuide)
            .constraints.first!
        
        collapsedConstraint = separatorContainer
            .pinEdges(.bottom, to: view.safeAreaLayoutGuide)
            .constraints.first!
        
        drawerContentView.addGestureRecognizer(swipeGesture)
        swipeGesture.delegate = self
        swipeGesture.gestureDelegate = self
        
        setExpanded(false, animated: false)
    }
    
    // MARK: - Interface
    
    func setExpanded(_ expanded: Bool, animated: Bool) {
        isExpanded = expanded
        delegate?.onSetExpanded(self, expanded)
        
        let updateLayout = {
            if expanded {
                self.collapsedConstraint?.isActive = false
                self.expandedConstraint?.isActive = true
            } else {
                self.expandedConstraint?.isActive = false
                self.collapsedConstraint?.isActive = true
            }
            
            self.collapsibleContentView.alpha = expanded ? 1 : 0
            self.collapsibleContentView.isUserInteractionEnabled = expanded
            
            self.bottomAreaContainer.backgroundColor =
                expanded ? .editorBackgroundOverlay : .editorBarOverlay
            
            self.separator.backgroundColor = 
                expanded ? separatorColor : .clear
            
            self.view.layoutIfNeeded()
            self.delegate?.onChangeDrawerSize(self)
        }
        
        if animated {
            UIView.animate(
                springDuration: animationDuration,
                bounce: animationBounce
            ) {
                updateLayout()
            }
        } else {
            updateLayout()
        }
    }
    
    func toggleExpanded() {
        setExpanded(!isExpanded, animated: true)
    }
    
}

extension AnimEditorDrawerVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        let safeAreaBounds = view.bounds
            .inset(by: UIEdgeInsets(
                top: 0, left: 0, bottom: 30, right: 0))
        
        let pos = touch.location(in: view)
        return safeAreaBounds.contains(pos)
    }
    
}

extension AnimEditorDrawerVC:
    AnimEditorDrawerSwipeGestureRecognizerDelegate {
    
    func onSwipe(up: Bool) {
        setExpanded(up, animated: true)
    }
    
}

// MARK: - Toolbar

class AnimEditorDrawerToolbar: UIView {
    
    let topShadowView = UIView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .editorBarOverlay
        
        pinHeight(to: toolbarHeight)
        
        topShadowView.backgroundColor = .editorBarShadow
        addSubview(topShadowView)
        topShadowView.pinEdges(.horizontal)
        topShadowView.pin(.bottom, toAnchor: .top)
        topShadowView.pinHeight(to: 1)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
