//
//  EditorFrameActiveDrawingRenderer.swift
//

import Foundation
import Metal

private let onionSkinPrevColor = Color(hex: "FF9600")
private let onionSkinNextColor = Color(hex: "2EBAFF")
private let onionSkinAlpha: Double = 0.5

protocol EditorFrameActiveDrawingRendererDelegate: AnyObject {
    
    func textureForActiveDrawing(
        _ r: EditorFrameActiveDrawingRenderer
    ) -> MTLTexture?
    
    func onionSkinPrevCount(
        _ r: EditorFrameActiveDrawingRenderer
    ) -> Int
    
    func onionSkinNextCount(
        _ r: EditorFrameActiveDrawingRenderer
    ) -> Int
    
    func textureForPrevOnionSkinDrawing(
        _ r: EditorFrameActiveDrawingRenderer,
        index: Int
    ) -> MTLTexture?
    
    func textureForNextOnionSkinDrawing(
        _ r: EditorFrameActiveDrawingRenderer,
        index: Int
    ) -> MTLTexture?
    
}

class EditorFrameActiveDrawingRenderer {
    
    weak var delegate: EditorFrameActiveDrawingRendererDelegate?
    
    private let spriteRenderer = SpriteRenderer()
    
    let renderTarget: MTLTexture
    
    init(
        drawingSize: PixelSize
    ) {
        let texDesc = MTLTextureDescriptor()
        texDesc.width = drawingSize.width
        texDesc.height = drawingSize.height
        texDesc.pixelFormat = AppConfig.pixelFormat
        texDesc.storageMode = .private
        texDesc.usage = [.renderTarget, .shaderRead]
        
        renderTarget = MetalInterface.shared.device
            .makeTexture(descriptor: texDesc)!
    }
    
    func draw() {
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: renderTarget,
            color: .clear)
        
        // Onion skin
        let onionSkinPrevCount = delegate?
            .onionSkinPrevCount(self) ?? 0
        
        let onionSkinNextCount = delegate?
            .onionSkinNextCount(self) ?? 0
        
        for index in 0 ..< onionSkinPrevCount {
            guard let texture = delegate?
                .textureForPrevOnionSkinDrawing(
                    self, index: index)
            else { continue }
            
            spriteRenderer.drawSprites(
                commandBuffer: commandBuffer,
                target: renderTarget,
                viewportSize: Size(1, 1),
                texture: texture,
                sprites: [
                    SpriteRenderer.Sprite(
                        size: Size(1, 1),
                        position: Vector(0.5, 0.5),
                        alpha: onionSkinAlpha)
                ],
                colorMode: .stencil,
                color: onionSkinPrevColor)
        }
        
        for index in 0 ..< onionSkinNextCount {
            guard let texture = delegate?
                .textureForNextOnionSkinDrawing(
                    self, index: index)
            else { continue }
            
            spriteRenderer.drawSprites(
                commandBuffer: commandBuffer,
                target: renderTarget,
                viewportSize: Size(1, 1),
                texture: texture,
                sprites: [
                    SpriteRenderer.Sprite(
                        size: Size(1, 1),
                        position: Vector(0.5, 0.5),
                        alpha: onionSkinAlpha)
                ],
                colorMode: .stencil,
                color: onionSkinNextColor)
        }
        
        // Active drawing
        if let drawingTexture = delegate?
            .textureForActiveDrawing(self)
        {
            spriteRenderer.drawSprites(
                commandBuffer: commandBuffer,
                target: renderTarget,
                viewportSize: Size(1, 1),
                texture: drawingTexture,
                sprites: [
                    SpriteRenderer.Sprite(
                        size: Size(1, 1),
                        position: Vector(0.5, 0.5))
                ])
        }
        
        commandBuffer.commit()
    }
    
}
