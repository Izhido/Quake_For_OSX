//
//  Shaders.metal
//  Quake_OSX
//
//  Created by Heriberto Delgado on 1/30/16.
//
//

#include <metal_stdlib>

using namespace metal;

struct VertexIn
{
    float4 position [[attribute(0)]];
    float2 texCoords [[attribute(1)]];
};

struct VertexOut
{
    float4 position [[position]];
    float2 texCoords;
};

vertex VertexOut vertexMain(VertexIn inVertex [[stage_in]], constant float4x4* modelViewProjectionMatrix [[buffer(1)]])
{
    VertexOut outVertex;
    outVertex.position = inVertex.position * (*modelViewProjectionMatrix);
    outVertex.texCoords = inVertex.texCoords;
    return outVertex;
}

fragment half4 fragmentMain(VertexOut input [[stage_in]], texture2d<half> diffuseTexture [[texture(0)]], texture1d<float> colorTableTexture [[texture(1)]], sampler diffuseSampler [[sampler(0)]], sampler colorTableSampler [[sampler(1)]])
{
    return half4(colorTableTexture.sample(colorTableSampler, diffuseTexture.sample(diffuseSampler, input.texCoords)[0]));
}
