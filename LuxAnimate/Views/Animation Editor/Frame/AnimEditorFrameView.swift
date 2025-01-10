//
//  AnimEditorFrameView.swift
//

import UIKit

class AnimEditorFrameView: PassthroughView {
    
    let toolbarContainer = UIView()
    let contentContainer = PassthroughView()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(toolbarContainer)
        addSubview(contentContainer)
        
        toolbarContainer.pinEdges([.top, .horizontal])
        
        contentContainer.pinEdges([.bottom, .horizontal])
        contentContainer.pin(
            .top, to: toolbarContainer,
            toAnchor: .bottom)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
