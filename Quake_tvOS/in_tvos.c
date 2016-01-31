//
//  in_tvos.c
//  Quake_tvOS
//
//  Created by Heriberto Delgado on 1/30/16.
//
//

#include "quakedef.h"

float   touch_x;
float   touch_y;

float   pitch_angle;
float   roll_angle;

cvar_t	in_pitchoffset = {"in_pitchoffset","45"};

cvar_t	in_rollthreshold = {"in_rollthreshold","0.174"};
cvar_t	in_rollscaling = {"in_rollscaling","0.4"};

cvar_t	in_touchthreshold = {"in_touchthreshold","0.001"};
cvar_t	in_touchscaling = {"in_touchscaling","2.5"};

void IN_Init (void)
{
    Cvar_RegisterVariable (&in_pitchoffset);
    Cvar_RegisterVariable (&in_rollthreshold);
    Cvar_RegisterVariable (&in_rollscaling);
    Cvar_RegisterVariable (&in_touchthreshold);
    Cvar_RegisterVariable (&in_touchscaling);
}

void IN_Shutdown (void)
{
}

void IN_Commands (void)
{
}

void IN_Move (usercmd_t *cmd)
{
    if (roll_angle >= in_rollthreshold.value)
    {
        cl.viewangles[YAW] += ((roll_angle - in_rollthreshold.value) * 90 * in_rollscaling.value);
    }
    else if (roll_angle <= -in_rollthreshold.value)
    {
        cl.viewangles[YAW] += ((roll_angle + in_rollthreshold.value) * 90 * in_rollscaling.value);
    }
    
    V_StopPitchDrift();
    
    cl.viewangles[PITCH] = pitch_angle * 90 + in_pitchoffset.value;
    if (cl.viewangles[PITCH] > 80)
        cl.viewangles[PITCH] = 80;
    if (cl.viewangles[PITCH] < -70)
        cl.viewangles[PITCH] = -70;
    
    if (key_dest == key_game)
    {
        float speed;
        
        if (in_speed.state & 1)
            speed = cl_movespeedkey.value;
        else
            speed = 1;
        
        if (touch_x >= in_touchthreshold.value || touch_x <= -in_touchthreshold.value)
        {
            cmd->sidemove += touch_x * in_touchscaling.value * speed * cl_sidespeed.value;
        }
        
        if (touch_y >= in_touchthreshold.value || touch_y <= -in_touchthreshold.value)
        {
            cmd->forwardmove -= touch_y * in_touchscaling.value * speed * cl_forwardspeed.value;
        }
    }
}
