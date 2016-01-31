//
//  Shaders.metal
//  Quake_OSX
//
//  Created by Heriberto Delgado on 1/30/16.
//
//

#include <metal_stdlib>

using namespace metal;

struct Vertex
{
    float4 position [[position, attribute(0)]];
    
    float2 texCoords [[attribute(1)]];
};

vertex Vertex vertexMain(Vertex inVertex [[stage_in]], constant float4x4* modelViewProjectionMatrix [[buffer(1)]])
{
    inVertex.position = inVertex.position * (*modelViewProjectionMatrix);
    
    return inVertex;
}

fragment half4 fragmentMain(Vertex input [[stage_in]], texture2d<half> diffuseTexture [[texture(0)]], texture1d<float> colorTableTexture [[texture(1)]], sampler diffuseSampler [[sampler(0)]], sampler colorTableSampler [[sampler(1)]])
{
    return half4(colorTableTexture.sample(colorTableSampler, diffuseTexture.sample(diffuseSampler, input.texCoords)[0]));
}
