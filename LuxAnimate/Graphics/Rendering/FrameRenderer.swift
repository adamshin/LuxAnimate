//
//  FrameRenderer.swift
//

import Metal

class FrameRenderer {
    
//    private let metalInterface: MetalInterface
//    
//    private let viewportWidth: Int
//    private let viewportHeight: Int
//    
//    private let pipelineState: MTLRenderPipelineState
//    
//    let framebuffer: MTLTexture
//    
//    init(
//        metalInterface: MetalInterface,
//        viewportWidth: Int,
//        viewportHeight: Int
//    ) {
//        self.metalInterface = metalInterface
//        self.viewportWidth = viewportWidth
//        self.viewportHeight = viewportHeight
//        
//        // Render pipeline
//        let library = metalInterface.device.makeDefaultLibrary()!
//        let vertexFunction = library.makeFunction(name: "textureVertexShader")
//        let fragmentFunction = library.makeFunction(name: "textureFragmentShader")
//        
//        let pipelineDescriptor = MTLRenderPipelineDescriptor()
//        pipelineDescriptor.vertexFunction = vertexFunction
//        pipelineDescriptor.fragmentFunction = fragmentFunction
//        
//        let attachment = pipelineDescriptor.colorAttachments[0]!
//        attachment.pixelFormat = .bgra8Unorm
//        
//        pipelineState = try! metalInterface.device
//            .makeRenderPipelineState(descriptor: pipelineDescriptor)
//        
//        // Framebuffer
//        let texDescriptor = MTLTextureDescriptor()
//        texDescriptor.textureType = .type2D
//        texDescriptor.width = viewportWidth
//        texDescriptor.height = viewportHeight
//        texDescriptor.pixelFormat = .bgra8Unorm
//        texDescriptor.storageMode = .private
//        texDescriptor.usage = [.renderTarget, .shaderRead]
//        
//        framebuffer = metalInterface.device
//            .makeTexture(descriptor: texDescriptor)!
//        
//        // Setup
//        clear()
//    }
//    
//    func clear() {
//        let commandBuffer = metalInterface.commandQueue
//            .makeCommandBuffer()!
//        
//        let renderPassDescriptor = MTLRenderPassDescriptor()
//        let attachment = renderPassDescriptor.colorAttachments[0]!
//        attachment.texture = framebuffer
//        attachment.storeAction = .store
//        attachment.loadAction = .clear
//        attachment.clearColor = MTLClearColorMake(0, 0, 0, 1)
//        
//        let renderEncoder = commandBuffer
//            .makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
//        renderEncoder.setRenderPipelineState(pipelineState)
//        
//        renderEncoder.endEncoding()
//        commandBuffer.commit()
//    }
//    
//    func render(canvas: Canvas) {
//        let commandBuffer = metalInterface.commandQueue
//            .makeCommandBuffer()!
//        
//        let renderPassDescriptor = MTLRenderPassDescriptor()
//        let attachment = renderPassDescriptor.colorAttachments[0]!
//        attachment.texture = framebuffer
//        attachment.storeAction = .store
//        attachment.loadAction = .clear
//        attachment.clearColor = canvas.backgroundColor.mtlClearColor
//        
//        let renderEncoder = commandBuffer
//            .makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
//        renderEncoder.setRenderPipelineState(pipelineState)
//        
//        if let framebuffer = canvas.brushEngine
//            .activeStrokeFramebuffer() {
//            
//            drawTexture(
//                renderEncoder: renderEncoder,
//                texture: framebuffer)
//            
//        } else {
//            drawTexture(
//                renderEncoder: renderEncoder,
//                texture: canvas.layer.texture)
//        }
//        
//        renderEncoder.endEncoding()
//        commandBuffer.commit()
//    }
//    
//    private func drawTexture(
//        renderEncoder: MTLRenderCommandEncoder,
//        texture: MTLTexture
//    ) {
//        let w = Float(canvasFormat.size.width)
//        let h = Float(canvasFormat.size.height)
//        
//        let vertexPositions: [(Float, Float)] = [
//            (0, 0), (0, 1), (1, 0), (1, 1)
//        ]
//        let vertices = vertexPositions.map { p in
//            TextureVertex(
//                position: .init(p.0 * w, p.1 * h),
//                texCoord: .init(p.0, p.1))
//        }
//        
//        let vertexBuffer = metalInterface.device.makeBuffer(
//            bytes: vertices,
//            length: vertices.count * MemoryLayout<TextureVertex>.stride)
//        
//        var frameData = FrameData(viewportSize: .init(
//            Float(canvasFormat.size.width),
//            Float(canvasFormat.size.height)))
//        let frameDataBuffer = metalInterface.device.makeBuffer(
//            bytes: &frameData,
//            length: MemoryLayout<FrameData>.size,
//            options: [])
//        
//        renderEncoder.setVertexBuffer(
//            vertexBuffer,
//            offset: 0,
//            index: Int(VertexBufferIndexVertices.rawValue))
//        
//        renderEncoder.setVertexBuffer(
//            frameDataBuffer,
//            offset: 0,
//            index: Int(VertexBufferIndexFrameData.rawValue))
//        
//        renderEncoder.setFragmentTexture(texture, index: 0)
//        
//        renderEncoder.drawPrimitives(
//            type: .triangleStrip,
//            vertexStart: 0,
//            vertexCount: vertices.count)
//    }
    
}
