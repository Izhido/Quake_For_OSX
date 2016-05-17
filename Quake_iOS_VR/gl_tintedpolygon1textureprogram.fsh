//
//  gl_tintedpolygon1textureprogram.fsh
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/14/16.
//
//

uniform mediump vec4 color;
uniform sampler2D texture;

varying mediump vec2 texcoords_fragment;

invariant gl_FragColor;

void main()
{
    gl_FragColor = color * texture2D(texture, fract(texcoords_fragment));
}
