//
//  AnimationFrameEditorRenderer.swift
//

import Foundation
import Metal

protocol AnimationFrameEditorRendererDelegate: AnyObject {
    
    func textureForDrawing(
        _ r: AnimationFrameEditorRenderer,
        drawingID: String
    ) -> MTLTexture?
    
}

class AnimationFrameEditorRenderer {
    
    weak var delegate: AnimationFrameEditorRendererDelegate?
    
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
    
    func draw(frameScene: AnimationEditorFrameScene) {
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: renderTarget,
            color: frameScene.backgroundColor)
        
        for layer in frameScene.layers {
            switch layer.content {
            case .activeDrawing(let content):
                drawActiveDrawingLayer(
                    commandBuffer: commandBuffer,
                    frameScene: frameScene,
                    layer: layer,
                    content: content)
            case .drawing(let content):
                drawDrawingLayer(
                    commandBuffer: commandBuffer,
                    frameScene: frameScene,
                    layer: layer,
                    content: content)
            }
        }
        
        commandBuffer.commit()
    }
    
    private func drawActiveDrawingLayer(
        commandBuffer: any MTLCommandBuffer,
        frameScene: AnimationEditorFrameScene,
        layer: AnimationEditorFrameScene.Layer,
        content: AnimationEditorFrameScene.ActiveDrawingLayerContent
    ) {
        let viewportSize = Size(
            Double(frameScene.viewportSize.width),
            Double(frameScene.viewportSize.height))
        
        let viewportCenter = Vector(
            viewportSize.width / 2,
            viewportSize.height / 2)
        
        let layerContentSize = Size(
            Double(layer.contentSize.width),
            Double(layer.contentSize.height))
        
        // Onion skins
        /*
        for drawing in content.prevOnionSkinDrawings {
            guard let texture = delegate?.textureForDrawing(self,
                drawingID: drawing.id)
            else { continue }
            
            spriteRenderer.drawSprites(
                commandBuffer: commandBuffer,
                target: renderTarget,
                viewportSize: viewportSize,
                texture: texture,
                sprites: [
                    SpriteRenderer.Sprite(
                        position: viewportCenter,
                        size: layerContentSize,
                        transform: layer.transform)
                ],
                colorMode: .stencil,
                color: .red)
        }
        
        for drawing in content.nextOnionSkinDrawings {
            guard let texture = delegate?.textureForDrawing(self,
                drawingID: drawing.id)
            else { continue }
            
            spriteRenderer.drawSprites(
                commandBuffer: commandBuffer,
                target: renderTarget,
                viewportSize: viewportSize,
                texture: texture,
                sprites: [
                    SpriteRenderer.Sprite(
                        position: viewportCenter,
                        size: layerContentSize)
                ],
                colorMode: .stencil,
                color: .green)
        }
         */
        
        // Drawing
        if let drawing = content.drawing,
            let texture = delegate?.textureForDrawing(self,
                drawingID: drawing.id)
        {
            spriteRenderer.drawSprites(
                commandBuffer: commandBuffer,
                target: renderTarget,
                viewportSize: viewportSize,
                texture: texture,
                sprites: [
                    SpriteRenderer.Sprite(
                        position: viewportCenter,
                        size: layerContentSize,
                        transform: layer.transform)
                ])
        }
    }
    
    private func drawDrawingLayer(
        commandBuffer: any MTLCommandBuffer,
        frameScene: AnimationEditorFrameScene,
        layer: AnimationEditorFrameScene.Layer,
        content: AnimationEditorFrameScene.DrawingLayerContent
    ) {
        guard let drawing = content.drawing,
            let texture = delegate?.textureForDrawing(self,
                drawingID: drawing.id)
        else { return }
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: renderTarget,
            viewportSize: Size(1, 1),
            texture: texture,
            sprites: [
                SpriteRenderer.Sprite(
                    position: Vector(0.5, 0.5),
                    size: Size(1, 1))
            ])
    }
    
}
