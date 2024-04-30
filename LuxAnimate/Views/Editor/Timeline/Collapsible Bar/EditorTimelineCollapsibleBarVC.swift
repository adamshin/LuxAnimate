//
//  EditorTimelineCollapsibleBarVC.swift
//

import UIKit

private let barHeight: CGFloat = 48

protocol EditorTimelineCollapsibleBarVCDelegate: AnyObject {
    
    func onSetExpanded(
        _ vc: EditorTimelineCollapsibleBarVC,
        _ expanded: Bool)
    
    func onModifyConstraints(
        _ vc: EditorTimelineCollapsibleBarVC)
    
}

class EditorTimelineCollapsibleBarVC: UIViewController {
    
    weak var delegate: EditorTimelineCollapsibleBarVCDelegate?
    
    let remainderAreaView = PassthroughView()
    let barView = EditorCollapsibleBarBarView()
    let contentView = UIView()
    
    private let contentCoverView = UIView()
    
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
        
        mainStack.addArrangedSubview(remainderAreaView)
        
        let barContentContainer = UIView()
        barContentContainer.backgroundColor = .editorBackground
        mainStack.addArrangedSubview(barContentContainer)
        
        let barContentStack = UIStackView()
        barContentStack.axis = .vertical
        barContentContainer.addSubview(barContentStack)
        barContentStack.pinEdges([.horizontal, .top])
        
        barContentStack.addArrangedSubview(barView)
        barContentStack.addArrangedSubview(contentView)
        barView.layer.zPosition = 1
        
        contentCoverView.backgroundColor = .editorBar
        
        view.addSubview(contentCoverView)
        contentCoverView.pinEdges(.horizontal)
        contentCoverView.pin(.top, to: barView, toAnchor: .bottom)
        contentCoverView.pin(.bottom)
        
        expandedConstraint = contentView
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
            
            self.contentCoverView.alpha = expanded ? 0 : 1
            self.contentCoverView.isUserInteractionEnabled = !expanded
            
            if animated {
                self.view.layoutIfNeeded()
            }
            
            self.delegate?.onModifyConstraints(self)
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
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .editorBar
        pinHeight(to: barHeight)
        
        let shadow1 = UIView()
        shadow1.backgroundColor = .editorBarShadow
        addSubview(shadow1)
        shadow1.pinEdges(.horizontal)
        shadow1.pin(.bottom, toAnchor: .top)
        shadow1.pinHeight(to: 1)
        
        let shadow2 = UIView()
        shadow2.backgroundColor = .editorBarShadow
        addSubview(shadow2)
        shadow2.pinEdges(.horizontal)
        shadow2.pin(.top, toAnchor: .bottom)
        shadow2.pinHeight(to: 1)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
