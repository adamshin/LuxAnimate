//
//  TestEditorView.swift
//

import UIKit

class TestEditorView: UIView {
    
    let workspaceContainer = UIView()
    let toolbarContainer = UIView()
    let toolControlsContainer = PassthroughView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .editorBackground
        
        addSubview(workspaceContainer)
        workspaceContainer.pinEdges()
        
        addSubview(toolbarContainer)
        toolbarContainer.pinEdges([.horizontal, .top])
        
        addSubview(toolControlsContainer)
        toolControlsContainer.pin(.top, to: toolbarContainer, toAnchor: .bottom)
        toolControlsContainer.pinEdges([.horizontal, .bottom])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
