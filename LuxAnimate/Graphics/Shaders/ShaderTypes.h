//
//  ShaderTypes.h
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

// MARK: - General

typedef enum
{
    ShaderBlendModeNormal = 0,
    ShaderBlendModeErase = 1,
    ShaderBlendModeReplace = 2,
} ShaderBlendMode;

typedef enum
{
    ShaderSampleModeNearest = 0,
    ShaderSampleModeLinear = 1,
    ShaderSampleModeLinearClampEdgeToBlack = 2,
} ShaderSampleMode;

typedef enum
{
    ShaderColorModeNone = 0,
    ShaderColorModeMultiply = 1,
    ShaderColorModeBrush = 2,
} ShaderColorMode;

// MARK: - Sprite

typedef enum
{
    SpriteVertexBufferIndexVertices = 0,
    SpriteVertexBufferIndexUniforms = 1,
} SpriteVertexBufferIndex;

typedef enum
{
    SpriteFragmentBufferIndexUniforms = 0,
} SpriteFragmentBufferIndex;

typedef struct
{
    simd_float2 viewportSize;
} SpriteVertexUniforms;

typedef struct
{
    ShaderBlendMode blendMode;
    ShaderSampleMode sampleMode;
    ShaderColorMode colorMode;
} SpriteFragmentUniforms;

typedef struct
{
    simd_float2 position;
    simd_float2 texCoord;
    simd_float4 color;
    float alpha;
} SpriteVertex;

#endif
