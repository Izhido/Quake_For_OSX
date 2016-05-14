//
//  gl_vidiosvr.c
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 1/30/16.
//
//

#include "quakedef.h"

#define WARP_WIDTH 320
#define WARP_HEIGHT 200

int	gl_screenwidth;
int gl_screenheight;

const char *gl_vendor;
const char *gl_renderer;
const char *gl_version;
const char *gl_extensions;

unsigned short	d_8to16table[256];
unsigned*	d_8to24table;
unsigned char d_15to8table[65536];

float		gldepthmin, gldepthmax;

qboolean isPermedia = false;
qboolean gl_mtexable = true;

//int		texture_mode = GL_NEAREST;
//int		texture_mode = GL_NEAREST_MIPMAP_NEAREST;
//int		texture_mode = GL_NEAREST_MIPMAP_LINEAR;
int		texture_mode = GL_LINEAR;
//int		texture_mode = GL_LINEAR_MIPMAP_NEAREST;
//int		texture_mode = GL_LINEAR_MIPMAP_LINEAR;

int		texture_extension_number = 1;

cvar_t	gl_ztrick = {"gl_ztrick","1"};

void GL_Init (void)
{
    gl_vendor = glGetString (GL_VENDOR);
    Con_Printf ("GL_VENDOR: %s\n", gl_vendor);
    gl_renderer = glGetString (GL_RENDERER);
    Con_Printf ("GL_RENDERER: %s\n", gl_renderer);
    
    gl_version = glGetString (GL_VERSION);
    Con_Printf ("GL_VERSION: %s\n", gl_version);
    gl_extensions = glGetString (GL_EXTENSIONS);
    Con_Printf ("GL_EXTENSIONS: %s\n", gl_extensions);
    
    //	Con_Printf ("%s %s\n", gl_renderer, gl_version);
    
    glClearColor (1,0,0,0);
    glCullFace(GL_FRONT);
    glEnable(GL_TEXTURE_2D);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
#if 0
    CheckArrayExtensions ();
    glEnable (GL_VERTEX_ARRAY_EXT);
    glEnable (GL_TEXTURE_COORD_ARRAY_EXT);
    glVertexPointerEXT (3, GL_FLOAT, 0, 0, &glv.x);
    glTexCoordPointerEXT (2, GL_FLOAT, 0, 0, &glv.s);
    glColorPointerEXT (3, GL_FLOAT, 0, 0, &glv.r);
#endif
}

void GL_BeginRendering (int *x, int *y, int *width, int *height)
{
    (*x) = 0;
    (*y) = 0;
    (*width) = gl_screenwidth;
    (*height) = gl_screenwidth;
}

void GL_EndRendering (void)
{
}

void	VID_SetPalette (unsigned char *palette)
{
    byte	*pal;
    unsigned r,g,b;
    unsigned v;
    unsigned short i;
    unsigned	*table;
    
    //
    // 8 8 8 encoding
    //
    pal = palette;
    table = d_8to24table;
    for (i=0 ; i<256 ; i++)
    {
        r = pal[0];
        g = pal[1];
        b = pal[2];
        pal += 3;
        
        v = (255 << 24) | (b << 16) | (g << 8) | r;
        *table++ = v;
    }
    d_8to24table[255] &= 0xFFFFFF;	// 255 is transparent
}

void	VID_ShiftPalette (unsigned char *palette)
{
    VID_SetPalette(palette);
}

void	VID_Init (unsigned char *palette)
{
	Cvar_RegisterVariable (&gl_ztrick);
    
    d_8to24table = malloc(256 * sizeof(unsigned));
    
    vid.width = vid.conwidth = vid.maxwarpwidth = WARP_WIDTH;
    vid.height = vid.conheight = vid.maxwarpheight = WARP_HEIGHT;
    vid.aspect = ((float)vid.height / (float)vid.width) * (320.0 / 240.0);
    vid.colormap = host_colormap;
    vid.fullbright = 256 - LittleLong (*((int *)vid.colormap + 2048));
    
    VID_SetPalette(palette);
    
    GL_Init ();
}

void	VID_Shutdown (void)
{
    if (d_8to24table != NULL)
    {
        free(d_8to24table);
    }
}
