//
//  PreviewFrameRenderer.swift
//

import Foundation
import Metal

protocol PreviewFrameRendererDelegate: AnyObject {
    
    func textureForAsset(
        _ r: PreviewFrameRenderer,
        assetID: String
    ) -> MTLTexture?
    
}

class PreviewFrameRenderer {
    
    weak var delegate: PreviewFrameRendererDelegate?
    
    private let spriteRenderer = SpriteRenderer()
    
    let renderTarget: MTLTexture
    
    init(
        viewportSize: PixelSize
    ) {
        let texDesc = MTLTextureDescriptor()
        texDesc.width = viewportSize.width
        texDesc.height = viewportSize.height
        texDesc.pixelFormat = AppConfig.pixelFormat
        texDesc.storageMode = .private
        texDesc.usage = [.renderTarget, .shaderRead]
        
        renderTarget = MetalInterface.shared.device
            .makeTexture(descriptor: texDesc)!
    }
    
    func draw(frameSceneGraph: PreviewFrameSceneGraph) {
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: renderTarget,
            color: frameSceneGraph.backgroundColor)
        
        for layer in frameSceneGraph.layers {
            switch layer {
            case .drawing(let drawingLayer):
                drawDrawingLayer(
                    commandBuffer: commandBuffer,
                    layer: drawingLayer)
            }
        }
        
        commandBuffer.commit()
    }
    
    private func drawDrawingLayer(
        commandBuffer: any MTLCommandBuffer,
        layer: PreviewFrameSceneGraph.DrawingLayer
    ) {
        guard let texture = delegate?.textureForAsset(
            self,
            assetID: layer.assetID)
        else { return }
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: renderTarget,
            viewportSize: Size(1, 1),
            texture: texture,
            sprites: [
                SpriteRenderer.Sprite(
                    size: Size(1, 1),
                    position: Vector(0.5, 0.5))
            ])
    }
    
}
