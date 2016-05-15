//
//  gl_coloredpolygonnotextureprogram.fsh
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/14/16.
//
//

varying mediump vec4 color_fragment;

invariant gl_FragColor;

void main()
{
    gl_FragColor = color_fragment;
}
