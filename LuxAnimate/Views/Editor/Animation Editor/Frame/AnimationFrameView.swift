//
//  AnimationFrameView.swift
//

import UIKit

class AnimationFrameView: UIView {
    
    let frameEditorContainer = UIView()
    let toolbarContainer = UIView()
    let canvasOverlayContainer = PassthroughView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .editorBackground
        
        addSubview(frameEditorContainer)
        frameEditorContainer.pinEdges()
        
        addSubview(toolbarContainer)
        toolbarContainer.pinEdges([.horizontal, .top])
        
        addSubview(canvasOverlayContainer)
        canvasOverlayContainer.pinEdges(.horizontal)
        canvasOverlayContainer.pin(.top, to: toolbarContainer, toAnchor: .bottom)
        canvasOverlayContainer.pin(.bottom, priority: .defaultLow)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setBottomInsetView(_ bottomInsetView: UIView) {
        canvasOverlayContainer.pin(.bottom, to: bottomInsetView, toAnchor: .top)
    }
    
}
