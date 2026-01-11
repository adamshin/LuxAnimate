//
//  AnimEditorView.swift
//

import UIKit

class AnimEditorView: UIView {
    
    let workspaceContainer = UIView()
    let toolbarContainer = UIView()
    let timelineContainer = UIView()
    
    let workspaceSafeAreaView = PassthroughView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .editorBackground
        
        addSubview(workspaceContainer)
        workspaceContainer.pinEdges()
        
        addSubview(toolbarContainer)
        toolbarContainer.pinEdges([.horizontal, .top])
        
        addSubview(timelineContainer)
        timelineContainer.pinEdges([.horizontal, .bottom])
        
        addSubview(workspaceSafeAreaView)
        workspaceSafeAreaView.pinEdges(.horizontal)
        workspaceSafeAreaView.pin(
            .top, to: toolbarContainer, toAnchor: .bottom)
        workspaceSafeAreaView.pin(
            .bottom, to: timelineContainer, toAnchor: .top)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
