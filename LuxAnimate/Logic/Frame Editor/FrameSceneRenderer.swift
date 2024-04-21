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
    
    private let sceneWidth: Scalar
    private let sceneHeight: Scalar
    private let pixelScale: Scalar
    
    private let framebuffer: MTLTexture
    private let pipelineState: MTLRenderPipelineState
    
    init(
        sceneWidth: Scalar,
        sceneHeight: Scalar,
        pixelScale: Scalar
    ) {
        self.sceneWidth = sceneWidth
        self.sceneHeight = sceneHeight
        self.pixelScale = pixelScale
        
        let canvasSize = PixelSize(
            width: lround(sceneWidth * pixelScale),
            height: lround(sceneHeight * pixelScale))
        
        // Framebuffer
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.width = canvasSize.width
        texDescriptor.height = canvasSize.height
        texDescriptor.pixelFormat = .rgba8Unorm
        texDescriptor.storageMode = .private
        texDescriptor.usage = [.renderTarget, .shaderRead]
        
        framebuffer = MetalInterface.shared.device
            .makeTexture(descriptor: texDescriptor)!
        
        // Render pipeline
        let library = MetalInterface.shared.device.makeDefaultLibrary()!
        let vertexFuction = library.makeFunction(name: "spriteVertexShader")
        let fragmentFunction = library.makeFunction(name: "spriteFragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFuction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        let attachment = pipelineDescriptor.colorAttachments[0]!
        attachment.pixelFormat = .rgba8Unorm
        
        pipelineState = try! MetalInterface.shared.device
            .makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        // Setup
        clear()
    }
    
    func getFramebuffer() -> MTLTexture { framebuffer }
    
    func clear() {
        let commandBuffer = MetalInterface.shared.commandQueue
            .makeCommandBuffer()!
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        let attachment = renderPassDescriptor.colorAttachments[0]!
        attachment.texture = framebuffer
        attachment.storeAction = .store
        attachment.loadAction = .clear
        attachment.clearColor = MTLClearColorMake(0, 0, 0, 1)
        
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.endEncoding()
        commandBuffer.commit()
    }
    
    func render(frameScene: FrameScene) {
        let commandBuffer = MetalInterface.shared.commandQueue
            .makeCommandBuffer()!
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        let attachment = renderPassDescriptor.colorAttachments[0]!
        attachment.texture = framebuffer
        attachment.storeAction = .store
        attachment.loadAction = .clear
        attachment.clearColor = MTLClearColorMake(1, 0, 0, 1)
        
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        
//        for layer in frameScene.layers {
//            renderLayer(
//                renderEncoder: renderEncoder,
//                layer: layer)
//        }
        
        renderEncoder.endEncoding()
        commandBuffer.commit()
    }
    
    private func renderLayer(
        renderEncoder: MTLRenderCommandEncoder,
        layer: FrameScene.Layer
    ) {
        switch layer.content {
        case .drawing(let drawing):
            guard let texture = delegate?
                .textureForDrawing(drawingID: drawing.id)
            else { return }
            
            renderDrawing(
                renderEncoder: renderEncoder,
                texture: texture,
                width: layer.width,
                height: layer.height,
                transform: layer.transform,
                alpha: layer.alpha,
                blendMode: layer.blendMode)
        }
    }
    
    private func renderDrawing(
        renderEncoder: MTLRenderCommandEncoder,
        texture: MTLTexture,
        width: Scalar,
        height: Scalar,
        transform: Matrix3,
        alpha: Double,
        blendMode: BlendMode
    ) {
        struct Vertex {
            var position: Vector
            var texCoord: Vector
        }
        let vertexPositions: [Vector] = [
            .init(0, 0), .init(0, 1),
            .init(1, 0), .init(1, 1)
        ]
        var vertices = vertexPositions.map {
            Vertex(
                position: $0,
                texCoord: $0)
        }
        vertices = vertices.map {
            var v = $0
            var pos = v.position
            
            pos = Matrix3(translation: .init(-0.5, -0.5)) * pos
            pos = Matrix3(scale: .init(width, height)) * pos
            pos = transform * pos
            pos = Matrix3(translation: .init(sceneWidth / 2, sceneHeight / 2)) * pos
            
            v.position = pos
            return v
        }
        
        let metalVertices = vertices.map {
            SpriteVertex(
                position: .init(
                    x: Float($0.position.x),
                    y: Float($0.position.y)),
                texCoord: .init(
                    x: Float($0.texCoord.x),
                    y: Float($0.texCoord.y)))
        }
        
        let vertexBuffer = MetalInterface.shared.device.makeBuffer(
            bytes: metalVertices,
            length: metalVertices.count * MemoryLayout<SpriteVertex>.stride)
        
        var spriteUniforms = SpriteVertexUniforms(viewportSize: .init(
            Float(sceneWidth),
            Float(sceneHeight)))
        
        let spriteUniformsBuffer = MetalInterface.shared.device.makeBuffer(
            bytes: &spriteUniforms,
            length: MemoryLayout<SpriteVertexUniforms>.size,
            options: [])
        
        renderEncoder.setVertexBuffer(
            vertexBuffer,
            offset: 0,
            index: Int(SpriteVertexBufferIndexVertices.rawValue))
        
        renderEncoder.setVertexBuffer(
            spriteUniformsBuffer,
            offset: 0,
            index: Int(SpriteVertexBufferIndexUniforms.rawValue))
        
        renderEncoder.setFragmentTexture(texture, index: 0)
        
        renderEncoder.drawPrimitives(
            type: .triangleStrip,
            vertexStart: 0,
            vertexCount: vertices.count)
    }
    
}
