
import Foundation
import Metal
import Geometry
import Color
import ShaderTypes

extension BrushStampRenderer {
    
    private static let quadPositions: [Vector] = [
        .init(0, 0), .init(1, 0), .init(1, 1),
        .init(0, 0), .init(1, 1), .init(0, 1),
    ]
    
    public struct Sprite {
        public var position: Vector
        public var size: Size
        public var anchor: Vector
        public var transform: Matrix3
        public var color: Color
        public var alpha: Double
        public var paddingScale: Double
        
        public init(
            position: Vector,
            size: Size,
            anchor: Vector = .init(0.5, 0.5),
            transform: Matrix3,
            color: Color = .white,
            alpha: Double = 1,
            paddingScale: Double = 1
        ) {
            self.position = position
            self.size = size
            self.anchor = anchor
            self.transform = transform
            self.color = color
            self.alpha = alpha
            self.paddingScale = paddingScale
        }
        
        public init(
            position: Vector,
            size: Size,
            anchor: Vector = .init(0.5, 0.5),
            rotation: Double = 0,
            scale: Double = 1,
            color: Color = .white,
            alpha: Double = 1,
            paddingScale: Double = 1
        ) {
            self.position = position
            self.size = size
            self.anchor = anchor
            self.color = color
            self.alpha = alpha
            self.paddingScale = paddingScale
            
            var t = Matrix3.identity
            t = Matrix3(scale: .init(scale, scale)) * t
            t = Matrix3(rotation: rotation) * t
            transform = t
        }
    }
    
}

public struct BrushStampRenderer {
    
    private let metalDevice: MTLDevice
    private let pipelineState: MTLRenderPipelineState
    
    public init(
        pixelFormat: MTLPixelFormat,
        metalDevice: MTLDevice
    ) {
        self.metalDevice = metalDevice
        
        let library = try! metalDevice
            .makeDefaultLibrary(bundle: Bundle.module)
        
        let vertexFunction = library.makeFunction(
            name: "brushStampVertexShader")
        let fragmentFunction = library.makeFunction(
            name: "brushStampFragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        let attachment = pipelineDescriptor.colorAttachments[0]!
        attachment.pixelFormat = pixelFormat
        
        pipelineState = try! metalDevice
            .makeRenderPipelineState(
                descriptor: pipelineDescriptor)
    }
    
    public func drawSprites(
        commandBuffer: MTLCommandBuffer,
        target: MTLTexture,
        viewportSize: Size,
        shapeTexture: MTLTexture,
        textureTexture: MTLTexture?,
        sprites: [Sprite],
        blendMode: BlendMode = .normal,
        sampleMode: SampleMode = .linear,
        colorMode: ColorMode = .none
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
        
        var vertices = Array<BrushStampVertex>()
        vertices.reserveCapacity(sprites.count * 6)
        
        for s in sprites {
            var t = Matrix3.identity
            t = Matrix3(translation: -s.anchor) * t
            t = Matrix3(scale: .init(s.size.width, s.size.height)) * t
            t = s.transform * t
            t = Matrix3(translation: s.position) * t
            
            for qp in Self.quadPositions {
                var p = qp
                p -= Vector(0.5, 0.5)
                p *= s.paddingScale
                p += Vector(0.5, 0.5)
                
                let tp = t * p
                let v = BrushStampVertex(
                    position: tp,
                    texCoord: p,
                    color: s.color,
                    alpha: s.alpha)
                
                vertices.append(v)
            }
        }
        
        let vertexBuffer = metalDevice.makeBuffer(
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
        
        renderEncoder.setFragmentTexture(shapeTexture, index: 0)
        
        if let textureTexture {
            renderEncoder.setFragmentTexture(textureTexture, index: 1)
        }
        
        renderEncoder.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: vertices.count)
         
        renderEncoder.endEncoding()
    }
    
}
