//
//  Shaders.metal
//

#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

// MARK: - Transforms

float2 viewportToClipSpace(float2 position, float2 viewportSize) {
    float2 normalizedPosition = position.xy / viewportSize;
    float2 clipSpacePosition = normalizedPosition * 2.0 - 1.0;
    clipSpacePosition.y = -clipSpacePosition.y;
    return clipSpacePosition;
}

// MARK: - Blending

float4 blendNormal(float4 c1, float4 c2) {
    float a1 = c1.a;
    float a2 = c2.a;
    
    float a = a1 + a2*(1 - a1);
    
    return float4(
        (c1.r * a1 + c2.r * a2 * (1 - a1)) / a,
        (c1.g * a1 + c2.g * a2 * (1 - a1)) / a,
        (c1.b * a1 + c2.b * a2 * (1 - a1)) / a,
        a
    );
}

float4 blend(
    float4 c1,
    float4 c2,
    ShaderBlendMode blendMode
 ) {
     // TODO: Switch blend mode
     return blendNormal(c1, c2);
 }

// MARK: - Sprite

struct SpriteVertexOutput {
    float4 position [[position]];
    float2 texCoord;
};

vertex SpriteVertexOutput spriteVertexShader(
                                             
    uint vertexID 
        [[vertex_id]],
                                             
    constant SpriteVertex *vertices
        [[buffer(SpriteVertexBufferIndexVertices)]],
                                             
    constant SpriteVertexUniforms& uniforms
        [[buffer(SpriteVertexBufferIndexUniforms)]]
) {
    SpriteVertex in = vertices[vertexID];
    SpriteVertexOutput out;
    
    float2 clipSpacePosition = viewportToClipSpace(
        in.position,
        uniforms.viewportSize);
    
    out.position = float4(clipSpacePosition, 0.0, 1.0);
    out.texCoord = in.texCoord;
    
    return out;
}

fragment float4 spriteFragmentShader(
                                     
    SpriteVertexOutput in 
        [[stage_in]],
                                     
    texture2d<float> texture 
        [[texture(0)]],
                                     
    constant SpriteFragmentUniforms& uniforms
        [[buffer(SpriteFragmentBufferIndexUniforms)]],
    
    float4 dst 
        [[color(0)]])
{
    sampler s(
        address::clamp_to_edge,
        mag_filter::linear,
        min_filter::linear,
        mip_filter::linear
    );
    
    float4 src = texture.sample(s, in.texCoord);
    src.a *= uniforms.alpha;
    
    return blend(src, dst, uniforms.blendMode);
}

// MARK: - Brush
/*

struct BrushVertexOutput {
    float4 position [[position]];
    float2 texCoord;
    float4 color;
    float alpha;
};

vertex BrushVertexOutput brushVertexShader(
    uint vertexID [[vertex_id]],
    constant BrushVertex *vertices [[buffer(VertexBufferIndexVertices)]],
    constant FrameData& frameData [[buffer(VertexBufferIndexFrameData)]]
) {
    BrushVertex in = vertices[vertexID];
    
    BrushVertexOutput out;
    
    float2 normalizedPosition = in.position.xy / frameData.viewportSize;
    float2 clipSpacePosition = normalizedPosition * 2.0 - 1.0;
    clipSpacePosition.y = -clipSpacePosition.y;
    out.position = float4(clipSpacePosition, 0.0, 1.0);
    
    out.texCoord = in.texCoord;
    out.color = in.color;
    out.alpha = in.alpha;
    
    return out;
}

fragment float4 brushFragmentShader(
    BrushVertexOutput in [[stage_in]],
    texture2d<float> texture [[texture(0)]],
    float4 dst [[color(0)]])
{
    sampler s(
        address::clamp_to_zero,
        mag_filter::linear,
        min_filter::linear,
        mip_filter::linear
    );
    float4 tex = texture.sample(s, in.texCoord);
    
    float4 src = in.color;
    src.a = src.a * tex.r * in.alpha;
    
    return blendNormal(src, dst);
}
*/
