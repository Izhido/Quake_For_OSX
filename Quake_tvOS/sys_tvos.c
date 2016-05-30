//
//  sys_tvos.c
//  Quake_tvOS
//
//  Created by Heriberto Delgado on 1/30/16.
//
//

#include "quakedef.h"
#include "errno.h"
#include <sys/stat.h>

extern double CACurrentMediaTime();

qboolean isDedicated;

static quakeparms_t parms;

float frame_lapse = 1.0 / 60.0;

char sys_resourcesdir[MAX_OSPATH];

char sys_documentsdir[MAX_OSPATH];

char** sys_messages = NULL;

int sys_messagescount = 0;

int sys_messagessize = 0;

qboolean sys_ended = false;

qboolean sys_inerror = false;

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
    mkdir (path, 0777);
}


/*
 ===============================================================================
 
 SYSTEM IO
 
 ===============================================================================
 */

void Sys_MakeCodeWriteable (unsigned long startaddr, unsigned long length)
{
}

void Sys_AddMessage(char* message)
{
    if (sys_messagescount >= sys_messagessize)
    {
        int newsize = sys_messagescount + 64;
        char** newmessages = malloc(newsize * sizeof(char*));
        
        if (sys_messages != NULL)
        {
            memcpy(newmessages, sys_messages, sys_messagescount * sizeof(char*));
            
            free(sys_messages);
        }
        
        sys_messages = newmessages;
        sys_messagessize = newsize;
    }
    
    sys_messages[sys_messagescount] = message;
    sys_messagescount++;
}

void Sys_Error (char *error, ...)
{
    va_list         argptr;
    
    char*		msg = malloc(MAXPRINTMSG);
    
    sprintf (msg,"Sys_Error: ");
    va_start (argptr,error);
    vsprintf (msg+strlen(msg),error,argptr);
    va_end (argptr);
    sprintf (msg+strlen(msg),"\n");
    
    printf("%s", msg);
    
    Sys_AddMessage (msg);
    
    Host_Shutdown();
    
    exit (1);
}

void Sys_Printf (char *fmt, ...)
{
    va_list         argptr;
    
    char*		msg = malloc(MAXPRINTMSG);
    
    va_start (argptr,fmt);
    vsprintf (msg,fmt,argptr);
    va_end (argptr);
    
    printf("%s", msg);
    
    Sys_AddMessage (msg);
}

void Sys_Quit (void)
{
    Host_Shutdown();
    
    exit (0);
}

double Sys_FloatTime (void)
{
    return CACurrentMediaTime();
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

void Sys_Init(const char* resourcesDir, const char* documentsDir)
{
    memset(sys_resourcesdir, 0, MAX_OSPATH);
    memcpy(sys_resourcesdir, resourcesDir, strlen(resourcesDir));
    
    memset(sys_documentsdir, 0, MAX_OSPATH);
    memcpy(sys_documentsdir, documentsDir, strlen(documentsDir));
    
    // Currently there is no way to access the documents folder from the device. Until that happens, keep these lines disabled:
    //printf("Documents=%s\n", sys_documentsdir);
    printf("Documents=%s\n", sys_resourcesdir);
    
    int argc = 3;
    
    //char* argv[] = { "Quake_tvOS", "-basedir", sys_documentsdir };
    char* argv[] = { "Quake_tvOS", "-basedir", sys_resourcesdir };
    
    parms.memsize = 8*1024*1024;
    parms.membase = malloc (parms.memsize);
    parms.basedir = ".";
    
    COM_InitArgv (argc, argv);
    
    parms.argc = com_argc;
    parms.argv = com_argv;
    
    isDedicated = (COM_CheckParm ("-dedicated") != 0);
    
    if (setjmp (host_abortserver) )
        return;			// something bad happened, or the server disconnected
    
    printf ("Host_Init\n");
    Host_Init (&parms);
}

void Sys_Frame()
{
    Host_Frame(frame_lapse);
}

int Sys_MessagesCount()
{
    return sys_messagescount;
}

char* Sys_GetMessage(int index)
{
    return sys_messages[index];
}
