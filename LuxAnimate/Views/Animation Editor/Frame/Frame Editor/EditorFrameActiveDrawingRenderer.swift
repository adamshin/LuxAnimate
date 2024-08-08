//
//  EditorFrameActiveDrawingRenderer.swift
//

import Foundation
import Metal

private let onionSkinPrevColor = Color(hex: "FF4444")
private let onionSkinNextColor = Color(hex: "22DD55")

private let onionSkinAlpha: Double = 0.6
private let onionSkinAlphaFalloff: Double = 0.2

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
        
        var onionSkinPrevAlpha = onionSkinAlpha
        
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
                        position: Vector(0.5, 0.5),
                        size: Size(1, 1),
                        alpha: onionSkinPrevAlpha)
                ],
                colorMode: .stencil,
                color: onionSkinPrevColor)
            
            onionSkinPrevAlpha -= onionSkinAlphaFalloff
        }
        
        let onionSkinNextCount = delegate?
            .onionSkinNextCount(self) ?? 0
        
        var onionSkinNextAlpha = onionSkinAlpha
        
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
                        position: Vector(0.5, 0.5),
                        size: Size(1, 1),
                        alpha: onionSkinNextAlpha)
                ],
                colorMode: .stencil,
                color: onionSkinNextColor)
            
            onionSkinNextAlpha -= onionSkinAlphaFalloff
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
                        position: Vector(0.5, 0.5),
                        size: Size(1, 1))
                ])
        }
        
        commandBuffer.commit()
    }
    
}
