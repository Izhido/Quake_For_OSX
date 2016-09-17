//
//  vid_tvos.c
//  Quake_tvOS
//
//  Created by Heriberto Delgado on 1/30/16.
//
//

#include "quakedef.h"
#include "d_local.h"

int	vid_screenWidth = 320;
int vid_screenHeight = 200;

int glvr_mode = 0;

byte*	vid_buffer = NULL;
short*	zbuffer = NULL;
byte*	surfcache = NULL;

unsigned short	d_8to16table[256];
unsigned*	d_8to24table;

void VID_SetSize(int width, int height)
{
    D_FlushCaches();
    
    if (surfcache != NULL)
    {
        free(surfcache);
    }
    
    if (zbuffer != NULL)
    {
        free(zbuffer);
    }
    
    if (vid_buffer != NULL)
    {
        free(vid_buffer);
    }
    
    vid_screenWidth = width;
    
    if (vid_screenWidth < 320)
    {
        vid_screenWidth = 320;
    }
    
    if (vid_screenWidth > 1280)
    {
        vid_screenWidth = 1280;
    }

    vid_screenHeight = height;
    
    if (vid_screenHeight < 200)
    {
        vid_screenHeight = 200;
    }
    
    if (vid_screenHeight > 960)
    {
        vid_screenHeight = 960;
    }
    
    if (vid_screenHeight > vid_screenWidth)
    {
        vid_screenHeight = vid_screenWidth;
    }
    
    vid_buffer = malloc(vid_screenWidth * vid_screenHeight * sizeof(byte));

    zbuffer = malloc(vid_screenWidth * vid_screenHeight * sizeof(short));

    vid.width = vid.conwidth = vid_screenWidth;
    vid.height = vid.conheight = vid_screenHeight;
    vid.aspect = ((float)vid.height / (float)vid.width) * (320.0 / 240.0);

    vid.buffer = vid.conbuffer = vid_buffer;
    vid.rowbytes = vid.conrowbytes = vid_screenWidth;
    
    d_pzbuffer = zbuffer;
    
    int surfcachesize = D_SurfaceCacheForRes(vid_screenWidth, vid_screenHeight);
    
    surfcache = malloc(surfcachesize);
    
    D_InitCaches (surfcache, surfcachesize);

    vid.recalc_refdef = 1;
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
    vid_buffer = malloc(vid_screenWidth * vid_screenHeight * sizeof(byte));
    zbuffer = malloc(vid_screenWidth * vid_screenHeight * sizeof(short));
    d_8to24table = malloc(256 * sizeof(unsigned));
    
    vid.maxwarpwidth = WARP_WIDTH;
    vid.maxwarpheight = WARP_HEIGHT;
    vid.width = vid.conwidth = vid_screenWidth;
    vid.height = vid.conheight = vid_screenHeight;
    vid.aspect = ((float)vid.height / (float)vid.width) * (320.0 / 240.0);
    vid.numpages = 1;
    vid.colormap = host_colormap;
    vid.fullbright = 256 - LittleLong (*((int *)vid.colormap + 2048));
    vid.buffer = vid.conbuffer = vid_buffer;
    vid.rowbytes = vid.conrowbytes = vid_screenWidth;
    
    d_pzbuffer = zbuffer;
    
    int surfcachesize = D_SurfaceCacheForRes(vid_screenWidth, vid_screenHeight);
    
    surfcache = malloc(surfcachesize);
    
    D_InitCaches (surfcache, surfcachesize);

    VID_SetPalette(palette);
}

void	VID_Shutdown (void)
{
    if (surfcache != NULL)
    {
        free(surfcache);
    }
    
    if (d_8to24table != NULL)
    {
        free(d_8to24table);
    }
    
    if (zbuffer != NULL)
    {
        free(zbuffer);
    }
    
    if (vid_buffer != NULL)
    {
        free(vid_buffer);
    }
}

void	VID_Update (vrect_t *rects)
{
}

/*
 ================
 D_BeginDirectRect
 ================
 */
void D_BeginDirectRect (int x, int y, byte *pbitmap, int width, int height)
{
}


/*
 ================
 D_EndDirectRect
 ================
 */
void D_EndDirectRect (int x, int y, int width, int height)
{
}
