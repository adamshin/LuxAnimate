//
//  EditorCollapsibleContentVC.swift
//

import UIKit

private let barHeight: CGFloat = 48

private let separatorColor = UIColor(white: 1, alpha: 0.04)

protocol EditorCollapsibleContentVCDelegate: AnyObject {
    
    func onSetExpanded(
        _ vc: EditorCollapsibleContentVC,
        _ expanded: Bool)
    
    func onChangeContentAreaSize(
        _ vc: EditorCollapsibleContentVC)
    
}

class EditorCollapsibleContentVC: UIViewController {
    
    weak var delegate: EditorCollapsibleContentVCDelegate?
    
    let contentAreaView = UIView()
    
    let barView = EditorCollapsibleBarBarView()
    let collapsibleContentView = UIView()
    
    private let bottomAreaContainer = UIView()
    private let separator = UIView()
    
    private let swipeUpGesture = UISwipeGestureRecognizer()
    private let swipeDownGesture = UISwipeGestureRecognizer()
    
    private var expandedConstraint: NSLayoutConstraint?
    private var collapsedConstraint: NSLayoutConstraint?
    
    private var isExpanded = false
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(contentAreaView)
        contentAreaView.pinEdges([.horizontal, .bottom])
        
        let blurView = ChromeBlurView()
        contentAreaView.addSubview(blurView)
        blurView.pinEdges()
        blurView.backgroundColor = .editorBarShadow
        
        let stack = UIStackView()
        stack.axis = .vertical
        contentAreaView.addSubview(stack)
        stack.pinEdges()
        
        stack.addArrangedSubview(barView)
        
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
        
        contentAreaView.addGestureRecognizer(swipeUpGesture)
        swipeUpGesture.addTarget(self, action: #selector(onSwipeUp))
        swipeUpGesture.direction = .up
        
        contentAreaView.addGestureRecognizer(swipeDownGesture)
        swipeDownGesture.addTarget(self, action: #selector(onSwipeDown))
        swipeDownGesture.direction = .down
        
        setExpanded(false, animated: false)
    }
    
    // MARK: - Handlers
    
    @objc private func onSwipeUp() {
        setExpanded(true, animated: true)
    }
    
    @objc private func onSwipeDown() {
        setExpanded(false, animated: true)
    }
    
    // MARK: - Interface
    
    func setExpanded(_ expanded: Bool, animated: Bool) {
        guard isExpanded != expanded else { return }
        
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
            self.delegate?.onChangeContentAreaSize(self)
        }
        
        if animated {
            UIView.animate(springDuration: 0.25) {
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

// MARK: - Bar View

class EditorCollapsibleBarBarView: UIView {
    
    let topShadowView = UIView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .editorBarOverlay
        
        pinHeight(to: barHeight)
        
        topShadowView.backgroundColor = .editorBarShadow
        addSubview(topShadowView)
        topShadowView.pinEdges(.horizontal)
        topShadowView.pin(.bottom, toAnchor: .top)
        topShadowView.pinHeight(to: 1)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
