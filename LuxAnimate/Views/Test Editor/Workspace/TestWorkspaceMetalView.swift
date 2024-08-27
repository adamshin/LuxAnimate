//
//  TestWorkspaceMetalView.swift
//

import UIKit

protocol TestWorkspaceMetalViewDelegate: AnyObject {
    func onRequestDraw(_ view: TestWorkspaceMetalView)
}

class TestWorkspaceMetalView: UIView {
    
    weak var delegate: TestWorkspaceMetalViewDelegate?
    
    override class var layerClass: AnyClass {
        CAMetalLayer.self
    }
    
    var metalLayer: CAMetalLayer {
        layer as! CAMetalLayer
    }
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        metalLayer.pixelFormat = AppConfig.metalLayerPixelFormat
        metalLayer.colorspace = CGColorSpace(name: CGColorSpace.sRGB)
        metalLayer.contentsGravity = .resize
        metalLayer.drawableSize = .zero
        
        metalLayer.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let scale = contentScaleFactor
        let drawableSize = CGSize(
            width: bounds.width * scale,
            height: bounds.height * scale)
        
        metalLayer.drawableSize = drawableSize
        delegate?.onRequestDraw(self)
    }
    
    override func draw(_ rect: CGRect) {
        delegate?.onRequestDraw(self)
    }
    
}

// MARK: - Delegates

extension TestWorkspaceMetalView {
    
    override func display(_ layer: CALayer) {
        delegate?.onRequestDraw(self)
    }
    
}
