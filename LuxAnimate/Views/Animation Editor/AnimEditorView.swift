//
//  AnimEditorView.swift
//

import UIKit

class AnimEditorView: UIView {
    
    let workspaceContainer = UIView()
    let toolbarContainer = UIView()
    let bottomBarContainer = UIView()
    let toolControlsContainer = PassthroughView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .editorBackground
        
        addSubview(workspaceContainer)
        workspaceContainer.pinEdges()
        
        addSubview(toolbarContainer)
        toolbarContainer.pinEdges([.horizontal, .top])
        
        addSubview(bottomBarContainer)
        bottomBarContainer.pinEdges([.horizontal, .bottom], to: safeAreaLayoutGuide)
        
        addSubview(toolControlsContainer)
        toolControlsContainer.pin(.top, to: toolbarContainer, toAnchor: .bottom)
        toolControlsContainer.pin(.bottom, to: bottomBarContainer, toAnchor: .top)
        toolControlsContainer.pinEdges(.horizontal)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
