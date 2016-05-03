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

void Sys_Init(const char* resourcesDir);

void Sys_Frame();