//
//  Quake_OSX-Bridging-Header.h
//  Quake_OSX
//
//  Created by Heriberto Delgado on 1/30/16.
//
//

#pragma once

extern float frame_lapse;

extern unsigned char* vid_buffer;

extern int vid_screenWidth;

extern int vid_screenHeight;

extern unsigned* d_8to24table;

extern int mx;

extern int my;

void Key_Event(int key, bool down);

void VID_SetSize(int width, int height);

void Sys_Init(int argc, char* argv[]);

void Sys_Frame();
