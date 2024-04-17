//
//  ShaderTypes.h
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef enum VertexBufferIndex
{
    VertexBufferIndexVertices = 0,
    VertexBufferIndexFrameData = 1,
} VertexBufferIndex;

typedef struct
{
    simd_float2 viewportSize;
} FrameData;

typedef struct
{
    simd_float2 position;
    simd_float4 color;
} ColorVertex;

typedef struct
{
    simd_float2 position;
    simd_float2 texCoord;
} TextureVertex;

typedef struct
{
    simd_float2 position;
    simd_float2 texCoord;
    simd_float4 color;
    float alpha;
} BrushVertex;

#endif
