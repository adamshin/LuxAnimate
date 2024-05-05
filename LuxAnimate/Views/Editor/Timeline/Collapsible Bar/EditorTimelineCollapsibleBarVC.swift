//
//  EditorTimelineCollapsibleBarVC.swift
//

import UIKit

private let barHeight: CGFloat = 48

private let separatorColor = UIColor(white: 1, alpha: 0.04)

protocol EditorTimelineCollapsibleBarVCDelegate: AnyObject {
    
    func onSetExpanded(
        _ vc: EditorTimelineCollapsibleBarVC,
        _ expanded: Bool)
    
    func onChangeConstraints(
        _ vc: EditorTimelineCollapsibleBarVC)
    
}

class EditorTimelineCollapsibleBarVC: UIViewController {
    
    weak var delegate: EditorTimelineCollapsibleBarVCDelegate?
    
    let barView = EditorCollapsibleBarBarView()
    let collapsibleContentView = UIView()
    
    let backgroundAreaView = PassthroughView()
    
    private let collapsibleContentContainer = UIView()
    
    private let separatorContainer = UIView()
    private let separator = UIView()
    
    private var expandedConstraint: NSLayoutConstraint?
    private var collapsedConstraint: NSLayoutConstraint?
    
    private var isExpanded = false
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainStack = PassthroughStackView()
        mainStack.axis = .vertical
        view.addSubview(mainStack)
        mainStack.pinEdges()
        
        mainStack.addArrangedSubview(backgroundAreaView)
        
        let contentContainer = UIView()
        mainStack.addArrangedSubview(contentContainer)
        
        let blurView = ChromeBlurView()
        contentContainer.addSubview(blurView)
        blurView.pinEdges()
        blurView.backgroundColor = .editorBarShadow
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentContainer.addSubview(contentStack)
        contentStack.pinEdges()
        
        contentStack.addArrangedSubview(barView)
        
        contentStack.addArrangedSubview(separatorContainer)
        separatorContainer.pinHeight(to: 1)
        separatorContainer.backgroundColor = .editorBarOverlay
        
        separatorContainer.addSubview(separator)
        separator.pinEdges()
        
        contentStack.addArrangedSubview(collapsibleContentContainer)
        collapsibleContentContainer.addSubview(collapsibleContentView)
        collapsibleContentView.pinEdges([.horizontal, .top])
        
        expandedConstraint = collapsibleContentView
            .pinEdges(.bottom, to: view.safeAreaLayoutGuide)
            .constraints.first!
        
        collapsedConstraint = barView
            .pinEdges(.bottom, to: view.safeAreaLayoutGuide)
            .constraints.first!
        
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
            
            self.collapsibleContentContainer.backgroundColor =
                expanded ? .editorBackgroundOverlay : .editorBarOverlay
            
            self.separator.backgroundColor = 
                expanded ? separatorColor : .clear
            
            if animated {
                self.view.layoutIfNeeded()
            }
            
            self.delegate?.onChangeConstraints(self)
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
