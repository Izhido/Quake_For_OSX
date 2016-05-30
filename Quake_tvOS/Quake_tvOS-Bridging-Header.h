//
//  Quake_tvOS-Bridging-Header.h
//  Quake_tvOS
//
//  Created by Heriberto Delgado on 1/30/16.
//
//

#pragma once

#include "quakedef.h"

extern float frame_lapse;

extern unsigned char* vid_buffer;

extern int vid_screenWidth;

extern int vid_screenHeight;

extern float in_touchx;

extern float in_touchy;

extern float in_pitchangle;

extern float in_rollangle;

extern qboolean in_extendedinuse;

extern float in_extendedforwardmove;

extern float in_extendedsidestepmove;

extern float in_extendedrollangle;

extern float in_extendedpitchangle;

extern int lanConfig_port;

extern char* lanConfig_joinname;

extern qboolean sys_ended;

extern qboolean sys_inerror;

void VID_SetSize(int width, int height);

void Sys_Cbuf_AddText(const char* text);

void Sys_Init(const char* resourcesDir, const char* documentsDir);

void Sys_Frame();

int Sys_MessagesCount();

char* Sys_GetMessage(int i);
