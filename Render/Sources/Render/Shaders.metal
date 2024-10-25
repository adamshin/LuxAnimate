
#include <metal_stdlib>
#include "../ShaderTypes/ShaderTypes.h"

using namespace metal;

// MARK: - General

float2 viewportToClipSpace(float2 position, float2 viewportSize) {
    float2 normalizedPosition = position.xy / viewportSize;
    float2 clipSpacePosition = normalizedPosition * 2.0 - 1.0;
    clipSpacePosition.y = -clipSpacePosition.y;
    return clipSpacePosition;
}

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

float4 blendErase(float4 c1, float4 c2) {
    c2.a *= (1 - c1.a);
    return c2;
}

float4 blend(
    float4 c1,
    float4 c2,
    ShaderBlendMode blendMode
) {
    switch (blendMode) {
        case ShaderBlendModeNormal:
            return blendNormal(c1, c2);
            
        case ShaderBlendModeErase:
            return blendErase(c1, c2);
            
        case ShaderBlendModeReplace:
            return c1;
            
        default:
            return blendNormal(c1, c2);
    }
}

sampler samplerForMode(
    ShaderSampleMode sampleMode
) {
    switch (sampleMode) {
        case ShaderSampleModeNearest:
            return sampler(
                address::clamp_to_edge,
                mag_filter::nearest,
                min_filter::nearest,
                mip_filter::none
            );
        case ShaderSampleModeLinear:
            return sampler(
                address::clamp_to_edge,
                mag_filter::linear,
                min_filter::linear,
                mip_filter::linear
            );
        case ShaderSampleModeLinearClampEdgeToBlack:
            return sampler(
                address::clamp_to_border,
                border_color::opaque_black,
                mag_filter::linear,
                min_filter::linear,
                mip_filter::linear
            );
        default:
            return sampler(
                address::clamp_to_edge,
                mag_filter::nearest,
                min_filter::nearest,
                mip_filter::none
            );
    }
}

float4 colorForColorMode(
    float4 textureColor,
    float4 vertexColor,
    ShaderColorMode colorMode
) {
    switch (colorMode) {
        case ShaderColorModeNone:
            return textureColor;
            
        case ShaderColorModeMultiply:
            return textureColor * vertexColor;
            
        case ShaderColorModeStencil: {
            float4 color = vertexColor;
            color.a = color.a * textureColor.a;
            return color;
        }
        case ShaderColorModeBrush: {
            float4 color = vertexColor;
            color.a = color.a * textureColor.r;
            return color;
        }
        
        default:
            return textureColor;
    }
}

// MARK: - Sprite

struct SpriteVertexOutput {
    float4 position [[position]];
    float2 texCoord;
    float4 color;
    float alpha;
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
    out.color = in.color;
    out.alpha = in.alpha;
    
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
    sampler s = samplerForMode(uniforms.sampleMode);
    
    float4 color = texture.sample(s, in.texCoord);
    color = colorForColorMode(color, in.color, uniforms.colorMode);
    color.a *= in.alpha;
    
    return blend(color, dst, uniforms.blendMode);
}
