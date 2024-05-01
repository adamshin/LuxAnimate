//
//  EditorPopupMenuVC.swift
//

import UIKit

class EditorPopupMenuVC: UIViewController {
    
    private let backgroundView = EditorPopupMenuBackgroundView()
    private let cardView = EditorPopupMenuCardView()
    
    private let dismissGesture = UITapGestureRecognizer()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundView)
        backgroundView.pinEdges()
        
        view.addSubview(cardView)
        cardView.pinCenter()
        cardView.pinWidth(to: 300)
        cardView.pinHeight(to: 400)
        
        backgroundView.addGestureRecognizer(dismissGesture)
        dismissGesture.addTarget(self, action: #selector(onDismiss))
    }
    
    @objc private func onDismiss() {
        dismiss(animated: false)
    }
    
}

class EditorPopupMenuBackgroundView: UIView {
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
