//
//  FrameEditorMetalView.swift
//

import UIKit
import Metal

protocol FrameEditorMetalViewDelegate: AnyObject {
    func draw(in layer: CAMetalLayer)
}

class FrameEditorMetalView: UIView {
    
    weak var delegate: FrameEditorMetalViewDelegate?
    
    override class var layerClass: AnyClass {
        CAMetalLayer.self
    }
    
    var metalLayer: CAMetalLayer {
        layer as! CAMetalLayer
    }
    
    init() {
        super.init(frame: .zero)
        
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.colorspace = CGColorSpace(name: CGColorSpace.sRGB)
        metalLayer.contentsGravity = .resize
        metalLayer.drawableSize = .zero
        
        metalLayer.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setDrawableSize(_ drawableSize: CGSize) {
        metalLayer.drawableSize = drawableSize
    }
    
    override func draw(_ rect: CGRect) {
        delegate?.draw(in: metalLayer)
    }
    
}

// MARK: - CALayerDelegate

extension FrameEditorMetalView {
    
    override func display(_ layer: CALayer) {
        delegate?.draw(in: metalLayer)
    }
    
}
