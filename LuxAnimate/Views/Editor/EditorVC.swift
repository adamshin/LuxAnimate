//
//  EditorVC.swift
//

import UIKit

class EditorVC: UIViewController {
    
    private let projectID: String
    
    private let workspaceVC = EditorWorkspaceVC()
    
    // MARK: - Initializer
    
    init(projectID: String) {
        self.projectID = projectID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addChild(workspaceVC, to: view)
        
        let topBar = UIView()
        view.addSubview(topBar)
        topBar.pinEdges([.horizontal, .top])
        topBar.pinHeight(to: 48)
        topBar.backgroundColor = .editorBar
        topBar.clipsToBounds = false
        
        let topBarShadow = UIView()
        topBarShadow.backgroundColor = .editorBarShadow
        topBar.addSubview(topBarShadow)
        topBarShadow.pinEdges(.horizontal)
        topBarShadow.pin(.top, toAnchor: .bottom)
        topBarShadow.pinHeight(to: 0.5)
        
        let bottomBar = UIView()
        view.addSubview(bottomBar)
        bottomBar.pinEdges([.horizontal, .bottom])
        bottomBar.pinHeight(to: 48)
        bottomBar.backgroundColor = .editorBar
        bottomBar.clipsToBounds = false
        
        let bottomBarShadow = UIView()
        bottomBarShadow.backgroundColor = .editorBarShadow
        bottomBar.addSubview(bottomBarShadow)
        bottomBarShadow.pinEdges(.horizontal)
        bottomBarShadow.pin(.bottom, toAnchor: .top)
        bottomBarShadow.pinHeight(to: 0.5)
        
        let resetButton = UIButton(type: .system)
        resetButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        resetButton.titleLabel?.tintColor = .editorLabel
        resetButton.setTitle("Reset", for: .normal)
        
        resetButton.addHandler { [weak self] in
            self?.onSelectResetCanvas()
        }
        
        topBar.addSubview(resetButton)
        resetButton.pin(.centerY)
        resetButton.pinEdges(.trailing, padding: 24)
    }
    
    // MARK: - UI
    
    private func updateUI() { }
    
    // MARK: - Handlers
    
    @objc private func onSelectResetCanvas() {
        workspaceVC.fitCanvasToBounds()
    }
    
}
