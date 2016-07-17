//
//  in_tvos.c
//  Quake_tvOS
//
//  Created by Heriberto Delgado on 1/30/16.
//
//

#include "quakedef.h"

float   in_touchx;
float   in_touchy;

float   in_pitchangle;
float   in_rollangle;

qboolean in_extendedinuse;

float   in_extendedforwardmove;
float   in_extendedsidestepmove;

float   in_extendedpitchangle;
float   in_extendedrollangle;

cvar_t	in_pitchoffset = {"in_pitchoffset","45"};

cvar_t	in_rollthreshold = {"in_rollthreshold","0.174"};
cvar_t	in_rollscaling = {"in_rollscaling","0.4"};

cvar_t	in_touchthreshold = {"in_touchthreshold","0.001"};
cvar_t	in_touchscaling = {"in_touchscaling","2.5"};

cvar_t	in_anglescaling = {"in_anglescaling","0.1"};

void IN_Init (void)
{
    Cvar_RegisterVariable (&in_pitchoffset);
    Cvar_RegisterVariable (&in_rollthreshold);
    Cvar_RegisterVariable (&in_rollscaling);
    Cvar_RegisterVariable (&in_touchthreshold);
    Cvar_RegisterVariable (&in_touchscaling);
    Cvar_RegisterVariable (&in_anglescaling);
}

void IN_Shutdown (void)
{
}

void IN_Commands (void)
{
}

void IN_Move (usercmd_t *cmd)
{
    if (in_extendedinuse)
    {
        if (in_extendedrollangle != 0.0 || in_extendedpitchangle != 0.0)
        {
            cl.viewangles[YAW] -= in_extendedrollangle * in_anglescaling.value * 90;
            
            cl.viewangles[PITCH] += in_extendedpitchangle * in_anglescaling.value * 90;
            
            if (cl.viewangles[PITCH] > 80)
                cl.viewangles[PITCH] = 80;
            if (cl.viewangles[PITCH] < -70)
                cl.viewangles[PITCH] = -70;
        }
        
        V_StopPitchDrift();
        
        if (key_dest == key_game)
        {
            float speed;
            
            if (in_speed.state & 1)
                speed = cl_movespeedkey.value;
            else
                speed = 1;
            
            cmd->sidemove += in_extendedforwardmove * speed * cl_forwardspeed.value;
            
            cmd->forwardmove += in_extendedsidestepmove * speed * cl_sidespeed.value;
        }
    }
    else
    {
        if (in_rollangle >= in_rollthreshold.value)
        {
            cl.viewangles[YAW] += ((in_rollangle - in_rollthreshold.value) * 90 * in_rollscaling.value);
        }
        else if (in_rollangle <= -in_rollthreshold.value)
        {
            cl.viewangles[YAW] += ((in_rollangle + in_rollthreshold.value) * 90 * in_rollscaling.value);
        }
        
        V_StopPitchDrift();
        
        cl.viewangles[PITCH] = in_pitchangle * 90 + in_pitchoffset.value;
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
            
            if (in_touchx >= in_touchthreshold.value || in_touchx <= -in_touchthreshold.value)
            {
                cmd->sidemove += in_touchx * in_touchscaling.value * speed * cl_sidespeed.value;
            }
            
            if (in_touchy >= in_touchthreshold.value || in_touchy <= -in_touchthreshold.value)
            {
                cmd->forwardmove -= in_touchy * in_touchscaling.value * speed * cl_forwardspeed.value;
            }
        }
    }
}
