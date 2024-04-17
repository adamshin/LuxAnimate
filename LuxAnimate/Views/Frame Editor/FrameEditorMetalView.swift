//
//  FrameEditorMetalView.swift
//

import UIKit
import Metal

protocol FrameEditorMetalViewDelegate: AnyObject {
    func render(in layer: CAMetalLayer)
}

class FrameEditorMetalView: UIView {
    
    weak var delegate: FrameEditorMetalViewDelegate?
    
    override class var layerClass: AnyClass {
        CAMetalLayer.self
    }
    
    var metalLayer: CAMetalLayer {
        layer as! CAMetalLayer
    }
    
    init(drawableSize: CGSize) {
        super.init(frame: .zero)
        
        metalLayer.contentsGravity = .bottomLeft
        metalLayer.framebufferOnly = false
        
        metalLayer.drawableSize = drawableSize
        metalLayer.pixelFormat = .bgra8Unorm
        
        metalLayer.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func draw(_ rect: CGRect) {
        render()
    }
    
    private func render() {
        delegate?.render(in: metalLayer)
    }
    
}

// MARK: - CALayerDelegate

extension FrameEditorMetalView {
    
    override func display(_ layer: CALayer) {
        render()
    }
    
}
