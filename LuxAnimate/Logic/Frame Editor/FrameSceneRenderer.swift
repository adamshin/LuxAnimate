//
//  FrameSceneRenderer.swift
//

import Foundation
import Metal

protocol FrameSceneRendererDelegate: AnyObject {
    func textureForDrawing(drawingID: String) -> MTLTexture?
}

class FrameSceneRenderer {
    
    weak var delegate: FrameSceneRendererDelegate?
    
    private let sceneSize: Size
    private let pixelScale: Scalar
    
    private let framebuffer: MTLTexture
    
    init(
        sceneSize: Size,
        pixelScale: Scalar
    ) {
        self.sceneSize = sceneSize
        self.pixelScale = pixelScale
        
        let canvasSize = PixelSize(
            width: lround(sceneSize.width * pixelScale),
            height: lround(sceneSize.height * pixelScale))
        
        // RenderTarget
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.width = canvasSize.width
        texDescriptor.height = canvasSize.height
        texDescriptor.pixelFormat = AppConfig.pixelFormat
        texDescriptor.storageMode = .private
        texDescriptor.usage = [.renderTarget, .shaderRead]
        
        framebuffer = MetalInterface.shared.device
            .makeTexture(descriptor: texDescriptor)!
    }
    
    func getRenderTarget() -> MTLTexture { framebuffer }
    
    func render(frameScene: FrameScene) {
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
//        for layer in frameScene.layers {
//            renderLayer(
//                renderEncoder: renderEncoder,
//                layer: layer)
//        }
        
        commandBuffer.commit()
    }
    
    private func renderLayer(
        commandBuffer: any MTLCommandBuffer,
        layer: FrameScene.Layer
    ) {
        switch layer.content {
        case .drawing(let drawing):
            guard let texture = delegate?
                .textureForDrawing(drawingID: drawing.id)
            else { return }
            
            renderDrawing(
                commandBuffer: commandBuffer,
                texture: texture,
                size: layer.size,
                transform: layer.transform,
                alpha: layer.alpha,
                blendMode: layer.blendMode)
        }
    }
    
    private func renderDrawing(
        commandBuffer: any MTLCommandBuffer,
        texture: MTLTexture,
        size: Size,
        transform: Matrix3,
        alpha: Double,
        blendMode: BlendMode
    ) {
        // TODO: Use sprite renderer
    }
    
}
