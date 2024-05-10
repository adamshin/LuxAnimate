//
//  EditorFrameRenderer.swift
//

import Foundation
import Metal

private let onionSkinPrevColor = Color(hex: "FEB941")
private let onionSkinNextColor = Color(hex: "5AB2FF")
private let onionSkinAlpha: Double = 0.7

class EditorFrameRenderer {
    
    private let backgroundColor: Color
    
    var drawingTexture: MTLTexture?
    var prevDrawingTexture: MTLTexture?
    var nextDrawingTexture: MTLTexture?
    
    var isOnionSkinOn = false
    
    let renderTarget: MTLTexture
    
    private let spriteRenderer = SpriteRenderer()
    
    init(
        drawingSize: PixelSize,
        backgroundColor: Color
    ) {
        self.backgroundColor = backgroundColor
        
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
            color: backgroundColor)
        
        if let prevDrawingTexture, isOnionSkinOn {
            spriteRenderer.drawSprites(
                commandBuffer: commandBuffer,
                target: renderTarget,
                viewportSize: Size(1, 1),
                texture: prevDrawingTexture,
                sprites: [
                    SpriteRenderer.Sprite(
                        size: Size(1, 1),
                        position: Vector(0.5, 0.5),
                        alpha: onionSkinAlpha)
                ],
                colorMode: .stencil,
                color: onionSkinPrevColor)
        }
        
        if let nextDrawingTexture, isOnionSkinOn {
            spriteRenderer.drawSprites(
                commandBuffer: commandBuffer,
                target: renderTarget,
                viewportSize: Size(1, 1),
                texture: nextDrawingTexture,
                sprites: [
                    SpriteRenderer.Sprite(
                        size: Size(1, 1),
                        position: Vector(0.5, 0.5),
                        alpha: onionSkinAlpha)
                ],
                colorMode: .stencil,
                color: onionSkinNextColor)
        }
        
        if let drawingTexture {
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
