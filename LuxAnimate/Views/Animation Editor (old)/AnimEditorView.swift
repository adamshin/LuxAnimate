//
//  AnimEditorView.swift
//

import UIKit

class AnimEditorView: UIView {
    
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
        toolControlsContainer.pinEdges()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
