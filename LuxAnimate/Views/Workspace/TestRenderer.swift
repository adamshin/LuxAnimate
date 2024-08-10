//
//  TestRenderer.swift
//

import Metal

struct TestRenderer {
    
    private let pipelineState: MTLRenderPipelineState
    private let texture: MTLTexture

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
        
        texture = createDefaultTexture(
            color: MTLClearColor(red: 1, green: 0, blue: 0, alpha: 1))!
    }
    
    func draw(
        commandBuffer: MTLCommandBuffer,
        target: MTLTexture
    ) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        
        let attachment = renderPassDescriptor.colorAttachments[0]!
        attachment.texture = target
        attachment.storeAction = .store
        attachment.loadAction = .load
        
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(
                descriptor: renderPassDescriptor)!
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        let vertices: [SpriteVertex] = [
            SpriteVertex(position: .init(0, 1), texCoord: .zero, color: .red, alpha: 1),
            SpriteVertex(position: .init(0.5, 0), texCoord: .zero, color: .green, alpha: 1),
            SpriteVertex(position: .init(1, 1), texCoord: .zero, color: .blue, alpha: 1),
        ]
        
        let vertexBuffer = MetalInterface.shared.device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<SpriteVertex>.stride)
        
        var vertexUniforms = SpriteVertexUniforms(
            viewportSize: .init(1, 1))
        
        var fragmentUniforms = SpriteFragmentUniforms(
            blendMode: BlendMode.normal.shaderValue,
            sampleMode: SampleMode.linear.shaderValue,
            colorMode: ColorMode.stencil.shaderValue)
        
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

private func createDefaultTexture(color: MTLClearColor) -> MTLTexture? {
    let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
        pixelFormat: .rgba8Unorm,
        width: 1,
        height: 1,
        mipmapped: false)
    textureDescriptor.usage = [.shaderRead, .shaderWrite]
    
    guard let texture = MetalInterface.shared.device
        .makeTexture(descriptor: textureDescriptor)
    else {
        print("Failed to create texture")
        return nil
    }
    
    let region = MTLRegionMake2D(0, 0, 1, 1)
    var c = simd_uchar4(
        UInt8(color.red * 255),
        UInt8(color.green * 255),
        UInt8(color.blue * 255),
        UInt8(color.alpha * 255))
    
    texture.replace(region: region, mipmapLevel: 0, withBytes: &c, bytesPerRow: 4)
    
    return texture
}
