//
//  gl_noalphatextprogram.fsh
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/14/16.
//
//

uniform sampler2D texture;
uniform mediump vec4 color;

varying mediump vec2 texcoords_fragment;

invariant gl_FragColor;

void main()
{
    gl_FragColor = color * texture2D(texture, texcoords_fragment);
}
