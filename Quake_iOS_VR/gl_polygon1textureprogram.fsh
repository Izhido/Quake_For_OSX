//
//  gl_polygon1textureprogram.fsh
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/14/16.
//
//

uniform sampler2D texture;

varying mediump vec2 texcoords_fragment;

invariant gl_FragColor;

void main()
{
    gl_FragColor = texture2D(texture, fract(texcoords_fragment));
}
