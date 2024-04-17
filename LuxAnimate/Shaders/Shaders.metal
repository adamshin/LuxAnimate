//
//  Shaders.metal
//

#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

// Utility Functions

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

// Color Vertex

struct ColorVertexOutput {
    float4 position [[position]];
    float4 color;
};

vertex ColorVertexOutput colorVertexShader(
    uint vertexID [[vertex_id]],
    constant ColorVertex *vertices [[buffer(VertexBufferIndexVertices)]],
    constant FrameData& frameData [[buffer(VertexBufferIndexFrameData)]]
) {
    ColorVertex in = vertices[vertexID];
    
    ColorVertexOutput out;
    
    float2 normalizedPosition = in.position.xy / frameData.viewportSize;
    float2 clipSpacePosition = normalizedPosition * 2.0 - 1.0;
    clipSpacePosition.y = -clipSpacePosition.y;
    out.position = float4(clipSpacePosition, 0.0, 1.0);
    
    out.color = in.color;
    
    return out;
}

fragment float4 colorFragmentShader(
    ColorVertexOutput in [[stage_in]],
    float4 dst [[color(0)]])
{
    float4 src = in.color;
    return blendNormal(src, dst);
}

// Texture Vertex

struct TextureVertexOutput {
    float4 position [[position]];
    float2 texCoord;
};

vertex TextureVertexOutput textureVertexShader(
    uint vertexID [[vertex_id]],
    constant TextureVertex *vertices [[buffer(VertexBufferIndexVertices)]],
    constant FrameData& frameData [[buffer(VertexBufferIndexFrameData)]]
) {
    TextureVertex in = vertices[vertexID];
    
    TextureVertexOutput out;
    
    float2 normalizedPosition = in.position.xy / frameData.viewportSize;
    float2 clipSpacePosition = normalizedPosition * 2.0 - 1.0;
    clipSpacePosition.y = -clipSpacePosition.y;
    out.position = float4(clipSpacePosition, 0.0, 1.0);
    
    out.texCoord = in.texCoord;
    
    return out;
}

fragment float4 textureFragmentShader(
    TextureVertexOutput in [[stage_in]],
    texture2d<float> texture [[texture(0)]],
    float4 dst [[color(0)]])
{
    sampler s(address::clamp_to_zero, filter::linear);
    float4 src = texture.sample(s, in.texCoord);
    return blendNormal(src, dst);
}

// Brush Vertex

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
