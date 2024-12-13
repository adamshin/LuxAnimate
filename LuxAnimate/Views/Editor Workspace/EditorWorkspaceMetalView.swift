//
//  EditorWorkspaceMetalView.swift
//

import UIKit

extension EditorWorkspaceMetalView {
    
    @MainActor
    protocol Delegate: AnyObject {
        func onRequestDraw(_ v: EditorWorkspaceMetalView)
    }
    
}

class EditorWorkspaceMetalView: UIView {
    
    weak var delegate: Delegate?
    
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

extension EditorWorkspaceMetalView {
    
    override func display(_ layer: CALayer) {
        delegate?.onRequestDraw(self)
    }
    
}
