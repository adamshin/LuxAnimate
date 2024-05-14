//
//  EditorFrameSceneRenderer.swift
//

import Foundation
import Metal

protocol EditorFrameSceneRendererDelegate: AnyObject {
    
    func textureForDrawing(
        _ r: EditorFrameSceneRenderer,
        drawingID: String
    ) -> MTLTexture?
    
}

class EditorFrameSceneRenderer {
    
    weak var delegate: EditorFrameSceneRendererDelegate?
    
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
    
    func draw(frameScene: FrameScene) {
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: renderTarget,
            color: frameScene.backgroundColor)
        
        for layer in frameScene.layers {
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
        layer: FrameSceneDrawingLayer
    ) {
        guard let texture = delegate?.textureForDrawing(
            self,
            drawingID: layer.drawing.id)
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
