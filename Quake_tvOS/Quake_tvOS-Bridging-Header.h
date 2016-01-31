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

extern float touch_x;

extern float touch_y;

extern float pitch_angle;

extern float roll_angle;

void VID_SetSize(int width, int height);

void Sys_Cbuf_AddText(const char* text);

void Sys_Init(const char* argv);

void Sys_Frame();
