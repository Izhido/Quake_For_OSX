//
//  gl_polygonnotextureprogram.fsh
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/14/16.
//
//

uniform mediump vec4 color;

invariant gl_FragColor;

void main()
{
    gl_FragColor = color;
}
