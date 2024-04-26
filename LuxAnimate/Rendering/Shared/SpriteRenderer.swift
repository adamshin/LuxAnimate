//
//  SpriteRenderer.swift
//

import Foundation
import Metal

struct SpriteRenderer {
    
    struct Sprite {
        var size: Size
        var position: Vector
        var rotation: Scalar = 0
        var scale: Scalar = 1
        var alpha: Double = 1
    }
    
    private let pipelineState: MTLRenderPipelineState
    
    init(
        pixelFormat: MTLPixelFormat = AppConfig.pixelFormat
    ) {
        let library = MetalInterface.shared.device
            .makeDefaultLibrary()!
        
        let vertexFunction = library.makeFunction(
            name: "spriteVertexShader")
        let fragmentFunction = library.makeFunction(
            name: "spriteFragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        let attachment = pipelineDescriptor.colorAttachments[0]!
        attachment.pixelFormat = pixelFormat
        
        pipelineState = try! MetalInterface.shared.device
            .makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func drawSprites(
        commandBuffer: any MTLCommandBuffer,
        target: MTLTexture,
        viewportSize: Size,
        texture: MTLTexture,
        sprites: [Sprite],
        blendMode: BlendMode = .normal,
        sampleMode: SampleMode = .linear,
        colorMode: ColorMode = .none,
        color: Color = .white
    ) {
        guard !sprites.isEmpty else { return }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        
        let attachment = renderPassDescriptor.colorAttachments[0]!
        attachment.texture = target
        attachment.storeAction = .store
        attachment.loadAction = .load
        
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(
                descriptor: renderPassDescriptor)!
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        var vertices: [SpriteVertex] = []
        
        for s in sprites {
            var t = Matrix3.identity
            t = Matrix3(translation: .init(-0.5, -0.5)) * t
            t = Matrix3(scale: .init(s.size.width, s.size.height)) * t
            t = Matrix3(scale: .init(s.scale, s.scale)) * t
            t = Matrix3(rotation: s.rotation) * t
            t = Matrix3(translation: s.position) * t
            
            let quadPositions: [Vector] = [
                .init(0, 0), .init(1, 0), .init(1, 1),
                .init(0, 0), .init(1, 1), .init(0, 1),
            ]
            let spriteVertices = quadPositions.map { p in
                let tp = t * p
                return SpriteVertex(
                    position: tp,
                    texCoord: p,
                    color: color,
                    alpha: s.alpha)
            }
            vertices += spriteVertices
        }
        
        let vertexBuffer = MetalInterface.shared.device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<SpriteVertex>.stride)
        
        var vertexUniforms = SpriteVertexUniforms(
            viewportSize: .init(
                Float(viewportSize.width),
                Float(viewportSize.height)))
        
        var fragmentUniforms = SpriteFragmentUniforms(
            blendMode: blendMode.shaderValue,
            sampleMode: sampleMode.shaderValue,
            colorMode: colorMode.shaderValue)
        
        renderEncoder.setVertexBuffer(
            vertexBuffer,
            offset: 0,
            index: Int(SpriteVertexBufferIndexVertices.rawValue))
        
        renderEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<SpriteVertexUniforms>.stride,
            index: Int(SpriteVertexBufferIndexUniforms.rawValue))
        
        renderEncoder.setFragmentBytes(
            &fragmentUniforms,
            length: MemoryLayout<SpriteFragmentUniforms>.stride,
            index: Int(SpriteFragmentBufferIndexUniforms.rawValue))
        
        renderEncoder.setFragmentTexture(texture, index: 0)
        
        renderEncoder.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: vertices.count)
         
        renderEncoder.endEncoding()
    }
    
}
