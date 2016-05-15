//
//  gl_coloredpolygon1textureprogram.fsh
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/14/16.
//
//

uniform sampler2D texture;

varying mediump vec2 texcoords_fragment;
varying mediump vec4 color_fragment;

invariant gl_FragColor;

void main()
{
    gl_FragColor = color_fragment * texture2D(texture, texcoords_fragment);
}
