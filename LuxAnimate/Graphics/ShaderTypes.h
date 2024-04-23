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
} ShaderBlendMode;

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
    float alpha;
    ShaderBlendMode blendMode;
} SpriteFragmentUniforms;

typedef struct
{
    simd_float2 position;
    simd_float2 texCoord;
} SpriteVertex;

// MARK: - Brush

/*
typedef enum BrushVertexBufferIndex
{
    BrushVertexBufferIndexVertices = 0,
    BrushVertexBufferIndexUniforms = 1,
} BrushVertexBufferIndex;

typedef enum
{
    BrushFragmentBufferIndexUniforms = 0,
} BrushFragmentBufferIndex;

typedef struct
{
    simd_float2 viewportSize;
} BrushVertexUniforms;

typedef struct
{
    RenderBlendMode blendMode;
} BrushFragmentUniforms;

typedef struct
{
    simd_float2 position;
    simd_float2 texCoord;
    simd_float4 color;
    float alpha;
} BrushVertex;
 */

#endif
