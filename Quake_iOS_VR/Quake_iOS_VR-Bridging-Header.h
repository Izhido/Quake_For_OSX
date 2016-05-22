//
//  Quake_iOS_VR-Bridging-Header.h
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/01/16.
//
//

#import <GCSCardboardView.h>

#include "quakedef.h"

extern float frame_lapse;

extern int gl_screenwidth;

extern int gl_screenheight;

extern float in_forwardmove;

extern float in_sidestepmove;

extern float in_rollangle;

extern float in_pitchangle;

void Sys_Cbuf_AddText(const char* text);

void Sys_Con_Printf(const char* text);

void Sys_Init(const char* resourcesDir);

void Sys_FrameBeforeRender();

void Sys_FrameRender();

void Sys_FrameAfterRender();
