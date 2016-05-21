//
//  sys_ios_vr.c
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/2/16.
//
//

#include "quakedef.h"
#include "errno.h"

qboolean isDedicated;

static quakeparms_t parms;

float frame_lapse = 1.0 / 60.0;

char gl_shaderdirectory[MAX_OSPATH];

char sys_resourcesdir[MAX_OSPATH];

extern int sb_updates;

/*
 ===============================================================================
 
 FILE IO
 
 ===============================================================================
 */

#define MAX_HANDLES             10
FILE    *sys_handles[MAX_HANDLES];

int             findhandle (void)
{
    int             i;
    
    for (i=1 ; i<MAX_HANDLES ; i++)
        if (!sys_handles[i])
            return i;
    Sys_Error ("out of handles");
    return -1;
}

/*
 ================
 filelength
 ================
 */
int filelength (FILE *f)
{
    int             pos;
    int             end;
    
    pos = ftell (f);
    fseek (f, 0, SEEK_END);
    end = ftell (f);
    fseek (f, pos, SEEK_SET);
    
    return end;
}

int Sys_FileOpenRead (char *path, int *hndl)
{
    FILE    *f;
    int             i;
    
    i = findhandle ();
    
    f = fopen(path, "rb");
    if (!f)
    {
        *hndl = -1;
        return -1;
    }
    sys_handles[i] = f;
    *hndl = i;
    
    return filelength(f);
}

int Sys_FileOpenWrite (char *path)
{
    FILE    *f;
    int             i;
    
    i = findhandle ();
    
    f = fopen(path, "wb");
    if (!f)
        Sys_Error ("Error opening %s: %s", path,strerror(errno));
    sys_handles[i] = f;
    
    return i;
}

void Sys_FileClose (int handle)
{
    fclose (sys_handles[handle]);
    sys_handles[handle] = NULL;
}

void Sys_FileSeek (int handle, int position)
{
    fseek (sys_handles[handle], position, SEEK_SET);
}

int Sys_FileRead (int handle, void *dest, int count)
{
    return fread (dest, 1, count, sys_handles[handle]);
}

int Sys_FileWrite (int handle, void *data, int count)
{
    return fwrite (data, 1, count, sys_handles[handle]);
}

int     Sys_FileTime (char *path)
{
    FILE    *f;
    
    f = fopen(path, "rb");
    if (f)
    {
        fclose(f);
        return 1;
    }
    
    return -1;
}

void Sys_mkdir (char *path)
{
}


/*
 ===============================================================================
 
 SYSTEM IO
 
 ===============================================================================
 */

void Sys_MakeCodeWriteable (unsigned long startaddr, unsigned long length)
{
}


void Sys_Error (char *error, ...)
{
    va_list         argptr;
    
    printf ("Sys_Error: ");
    va_start (argptr,error);
    vprintf (error,argptr);
    va_end (argptr);
    printf ("\n");
    
    exit (1);
}

void Sys_Printf (char *fmt, ...)
{
    va_list         argptr;
    
    va_start (argptr,fmt);
    vprintf (fmt,argptr);
    va_end (argptr);
}

void Sys_Quit (void)
{
    exit (0);
}

double Sys_FloatTime (void)
{
    static double t;
    
    t += frame_lapse;
    
    return t;
}

char *Sys_ConsoleInput (void)
{
    return NULL;
}

void Sys_Sleep (void)
{
}

void Sys_SendKeyEvents (void)
{
}

void Sys_HighFPPrecision (void)
{
}

void Sys_LowFPPrecision (void)
{
}

void Sys_Cbuf_AddText(const char* text)
{
    Cbuf_AddText(text);
}

char* Sys_LoadTextFromFile(const char* directory, const char* filename)
{
    char* fullpath = malloc(strlen(directory) + strlen(filename) + 2);
    
    strcpy(fullpath, directory);
    strcat(fullpath, "/");
    strcat(fullpath, filename);
    
    int handle = -1;
    
    int length = Sys_FileOpenRead(fullpath, &handle);
    
    char* result = NULL;
    
    if (handle >= 0 && length > 0)
    {
        result = malloc(length + 1);
        
        Sys_FileRead(handle, result, length);

        result[length] = 0;
    }
    
    Sys_FileClose(handle);
    
    free(fullpath);
    
    return result;
}

void Sys_Init(const char* resourcesDir)
{
    memset(sys_resourcesdir, 0, MAX_OSPATH);
    
    memcpy(sys_resourcesdir, resourcesDir, strlen(resourcesDir));

    int argc = 3;
    
    char* argv[] = { "Quake_iOS_VR", "-basedir", sys_resourcesdir };
    
    parms.memsize = 8*1024*1024;
    parms.membase = malloc (parms.memsize);
    parms.basedir = ".";
    
    COM_InitArgv (argc, argv);
    
    parms.argc = com_argc;
    parms.argv = com_argv;
    
    isDedicated = (COM_CheckParm ("-dedicated") != 0);

    strcpy(gl_shaderdirectory, resourcesDir);
    
    printf ("Host_Init\n");
    Host_Init (&parms);
}

void Sys_FrameBeforeRender()
{
    if (setjmp (host_abortserver) )
        return;			// something bad happened, or the server disconnected

    sb_updates = 0;
    
    block_drawing = true;
    
    Host_FrameBeforeRender(frame_lapse);
}

void Sys_FrameRender()
{
    block_drawing = false;
    
    glViewport(glvr_viewportx, glvr_viewporty, glvr_viewportwidth, glvr_viewportheight);
    glScissor(glvr_viewportx, glvr_viewporty, glvr_viewportwidth, glvr_viewportheight);

    SCR_UpdateScreen();
    
    block_drawing = true;
}

void Sys_FrameAfterRender()
{
    Host_FrameAfterRender();
    
    host_framecount++;
}
