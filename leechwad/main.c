#include "scriplib.h"
#include "wadlib.h"
#include "bspfile.h"
#include <sys/stat.h>

#define    MAX_QPATH        64            // max length of a quake game pathname
#define    MAX_OSPATH        1024        // max length of a filesystem pathname

#define MAX_FILES_IN_PACK       2048

typedef struct
{
    char    name[MAX_QPATH];
    int             filepos, filelen;
} packfile_t;

typedef struct pack_s
{
    char    filename[MAX_OSPATH];
    int             handle;
    int             numfiles;
    packfile_t      *files;
} pack_t;

//
// on disk
//
typedef struct
{
    char    name[56];
    int             filepos, filelen;
} dpackfile_t;

typedef struct
{
    char    id[4];
    int             dirofs;
    int             dirlen;
} dpackheader_t;

unsigned char palette[] =
{
    0, 0, 0, 15, 15, 15, 31, 31, 31, 47, 47, 47, 63, 63, 63, 75, 75, 75,
    91, 91, 91, 107, 107, 107, 123, 123, 123, 139, 139, 139, 155, 155, 155, 171, 171, 171,
    187, 187, 187, 203, 203, 203, 219, 219, 219, 235, 235, 235, 15, 11, 7, 23, 15, 11,
    31, 23, 11, 39, 27, 15, 47, 35, 19, 55, 43, 23, 63, 47, 23, 75, 55, 27,
    83, 59, 27, 91, 67, 31, 99, 75, 31, 107, 83, 31, 115, 87, 31, 123, 95, 35,
    131, 103, 35, 143, 111, 35, 11, 11, 15, 19, 19, 27, 27, 27, 39, 39, 39, 51,
    47, 47, 63, 55, 55, 75, 63, 63, 87, 71, 71, 103, 79, 79, 115, 91, 91, 127,
    99, 99, 139, 107, 107, 151, 115, 115, 163, 123, 123, 175, 131, 131, 187, 139, 139, 203,
    0, 0, 0, 7, 7, 0, 11, 11, 0, 19, 19, 0, 27, 27, 0, 35, 35, 0,
    43, 43, 7, 47, 47, 7, 55, 55, 7, 63, 63, 7, 71, 71, 7, 75, 75, 11,
    83, 83, 11, 91, 91, 11, 99, 99, 11, 107, 107, 15, 7, 0, 0, 15, 0, 0,
    23, 0, 0, 31, 0, 0, 39, 0, 0, 47, 0, 0, 55, 0, 0, 63, 0, 0,
    71, 0, 0, 79, 0, 0, 87, 0, 0, 95, 0, 0, 103, 0, 0, 111, 0, 0,
    119, 0, 0, 127, 0, 0, 19, 19, 0, 27, 27, 0, 35, 35, 0, 47, 43, 0,
    55, 47, 0, 67, 55, 0, 75, 59, 7, 87, 67, 7, 95, 71, 7, 107, 75, 11,
    119, 83, 15, 131, 87, 19, 139, 91, 19, 151, 95, 27, 163, 99, 31, 175, 103, 35,
    35, 19, 7, 47, 23, 11, 59, 31, 15, 75, 35, 19, 87, 43, 23, 99, 47, 31,
    115, 55, 35, 127, 59, 43, 143, 67, 51, 159, 79, 51, 175, 99, 47, 191, 119, 47,
    207, 143, 43, 223, 171, 39, 239, 203, 31, 255, 243, 27, 11, 7, 0, 27, 19, 0,
    43, 35, 15, 55, 43, 19, 71, 51, 27, 83, 55, 35, 99, 63, 43, 111, 71, 51,
    127, 83, 63, 139, 95, 71, 155, 107, 83, 167, 123, 95, 183, 135, 107, 195, 147, 123,
    211, 163, 139, 227, 179, 151, 171, 139, 163, 159, 127, 151, 147, 115, 135, 139, 103, 123,
    127, 91, 111, 119, 83, 99, 107, 75, 87, 95, 63, 75, 87, 55, 67, 75, 47, 55,
    67, 39, 47, 55, 31, 35, 43, 23, 27, 35, 19, 19, 23, 11, 11, 15, 7, 7,
    187, 115, 159, 175, 107, 143, 163, 95, 131, 151, 87, 119, 139, 79, 107, 127, 75, 95,
    115, 67, 83, 107, 59, 75, 95, 51, 63, 83, 43, 55, 71, 35, 43, 59, 31, 35,
    47, 23, 27, 35, 19, 19, 23, 11, 11, 15, 7, 7, 219, 195, 187, 203, 179, 167,
    191, 163, 155, 175, 151, 139, 163, 135, 123, 151, 123, 111, 135, 111, 95, 123, 99, 83,
    107, 87, 71, 95, 75, 59, 83, 63, 51, 67, 51, 39, 55, 43, 31, 39, 31, 23,
    27, 19, 15, 15, 11, 7, 111, 131, 123, 103, 123, 111, 95, 115, 103, 87, 107, 95,
    79, 99, 87, 71, 91, 79, 63, 83, 71, 55, 75, 63, 47, 67, 55, 43, 59, 47,
    35, 51, 39, 31, 43, 31, 23, 35, 23, 15, 27, 19, 11, 19, 11, 7, 11, 7,
    255, 243, 27, 239, 223, 23, 219, 203, 19, 203, 183, 15, 187, 167, 15, 171, 151, 11,
    155, 131, 7, 139, 115, 7, 123, 99, 7, 107, 83, 0, 91, 71, 0, 75, 55, 0,
    59, 43, 0, 43, 31, 0, 27, 15, 0, 11, 7, 0, 0, 0, 255, 11, 11, 239,
    19, 19, 223, 27, 27, 207, 35, 35, 191, 43, 43, 175, 47, 47, 159, 47, 47, 143,
    47, 47, 127, 47, 47, 111, 47, 47, 95, 43, 43, 79, 35, 35, 63, 27, 27, 47,
    19, 19, 31, 11, 11, 15, 43, 0, 0, 59, 0, 0, 75, 7, 0, 95, 7, 0,
    111, 15, 0, 127, 23, 7, 147, 31, 7, 163, 39, 11, 183, 51, 15, 195, 75, 27,
    207, 99, 43, 219, 127, 59, 227, 151, 79, 231, 171, 95, 239, 191, 119, 247, 211, 139,
    167, 123, 59, 183, 155, 55, 199, 195, 55, 231, 227, 87, 127, 191, 255, 171, 231, 255,
    215, 255, 255, 103, 0, 0, 139, 0, 0, 179, 0, 0, 215, 0, 0, 255, 0, 0,
    255, 243, 147, 255, 247, 199, 255, 255, 255, 159, 91, 83
};

#define TEXTURE_LEN 16

#define MAX_HANDLES             10

FILE    *sys_handles[MAX_HANDLES];

int             findhandle (void)
{
    int             i;
    
    for (i=1 ; i<MAX_HANDLES ; i++)
        if (!sys_handles[i])
            return i;
    printf ("out of handles");
    return -1;
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
    {
        printf ("Error opening %s: %s", path,strerror(errno));
        return -1;
    }
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

int main(int argc, char* argv[])
{
    if (argc != 4)
    {
        Error("Usage: leechwad mapfile.map pakfile.pak output.wad");
    }
    LoadScriptFile(argv[1]);
    int maxtextures = 512;
    int numtextures = 0;
    char* textures = malloc(maxtextures * TEXTURE_LEN);
    do
    {
        if (!GetToken(true))
        {
            break;
        }
        if (endofscript)
        {
            break;
        }
        if (strcmp(token, "{"))
        {
            Error("leechwad: { not found.");
        }
        do
        {
            if (!GetToken(true))
            {
                break;
            }
            if (endofscript)
            {
                break;
            }
            if (!strcmp(token, "}"))
            {
                break;
            }
            if (!strcmp(token, "{"))
            {
                do
                {
                    if (!GetToken(true))
                    {
                        break;
                    }
                    if (endofscript)
                    {
                        break;
                    }
                    if (!strcmp(token, "}"))
                    {
                        break;
                    }
                    for (int i = 0; i < 3; i++)
                    {
                        if (i != 0)
                        {
                            GetToken(true);
                        }
                        if (strcmp(token, "("))
                        {
                            Error("leechwad: ( not found.");
                        }
                        GetToken(false);
                        GetToken(false);
                        GetToken(false);
                        GetToken(false);
                        if (strcmp(token, ")"))
                        {
                            Error("leechwad: ) not found.");
                        }
                    }
                    GetToken(false);
                    if (strlen(token) >= 16)
                    {
                        Error("leechwad: texture name too long.");
                    }
                    char texture[TEXTURE_LEN];
                    strcpy(texture, token);
                    GetToken(false);
                    GetToken(false);
                    GetToken(false);
                    GetToken(false);
                    GetToken(false);
                    qboolean found = false;
                    for (int i = 0; i < numtextures; i++)
                    {
                        if (!strncmp(texture, textures + i * TEXTURE_LEN, TEXTURE_LEN))
                        {
                            found = true;
                            break;
                        }
                    }
                    if (!found)
                    {
                        numtextures++;
                        if (numtextures < maxtextures)
                        {
                            int newmaxtextures = maxtextures + 512;
                            char* newtextures = malloc(newmaxtextures);
                            memcpy(newtextures, textures, maxtextures);
                            free(textures);
                            textures = newtextures;
                            maxtextures = newmaxtextures;
                        }
                        strcpy(textures + (numtextures - 1) * TEXTURE_LEN, texture);
                    }
                } while (true);
            }
            else
            {
                GetToken(false);
            }
        } while(true);
    } while(true);

    dpackheader_t   header;
    int                             i;
    packfile_t              *newfiles;
    int                             numpackfiles;
    int                             packhandle;
    dpackfile_t             info[MAX_FILES_IN_PACK];
    unsigned short          crc;
    char* packfile = argv[2];
    
    if (Sys_FileOpenRead (packfile, &packhandle) == -1)
    {
        printf ("Couldn't open %s\n", packfile);
        return EXIT_FAILURE;
    }
    Sys_FileRead (packhandle, (void *)&header, sizeof(header));
    if (header.id[0] != 'P' || header.id[1] != 'A'
        || header.id[2] != 'C' || header.id[3] != 'K')
    {
        printf ("%s is not a packfile", packfile);
        return EXIT_FAILURE;
    }
    header.dirofs = LittleLong (header.dirofs);
    header.dirlen = LittleLong (header.dirlen);
    
    numpackfiles = header.dirlen / sizeof(dpackfile_t);
    
    newfiles = malloc (numpackfiles * sizeof(packfile_t));
    
    Sys_FileSeek (packhandle, header.dirofs);
    Sys_FileRead (packhandle, (void *)info, header.dirlen);
    
    // crc the directory to check for modifications
    CRC_Init (&crc);
    for (i=0 ; i<header.dirlen ; i++)
        CRC_ProcessByte (&crc, ((byte *)info)[i]);
    
    // parse the directory
    for (i=0 ; i<numpackfiles ; i++)
    {
        strcpy (newfiles[i].name, info[i].name);
        newfiles[i].filepos = LittleLong(info[i].filepos);
        newfiles[i].filelen = LittleLong(info[i].filelen);
    }
    
    pack_t pack;
    strcpy (pack.filename, packfile);
    pack.handle = packhandle;
    pack.numfiles = numpackfiles;
    pack.files = newfiles;

    W_NewWad(argv[3], false);
    W_AddLump("PALETTE", palette, 768, TYP_LUMPY, false);
    int lumpsize = sizeof(miptex_t) + 64 * 64 + 32 * 32 + 16 * 16 + 8 * 8;
    unsigned char* lump = malloc(lumpsize);
    miptex_t* miptex = (miptex_t*)lump;
    miptex->width = 64;
    miptex->height = 64;
    miptex->offsets[0] = sizeof(miptex_t);
    miptex->offsets[1] = miptex->offsets[0] + 64 * 64;
    miptex->offsets[2] = miptex->offsets[1] + 32 * 32;
    miptex->offsets[3] = miptex->offsets[2] + 16 * 16;
    time_t fortemp = time(0);
    for (int i = 0; i < numtextures; i++)
    {
        bzero(miptex->name, TEXTURE_LEN);
        strcpy(miptex->name, textures + i * TEXTURE_LEN);
        qboolean found = false;
        for (int j = 0; j < pack.numfiles; j++)
        {
            int namelen = strlen(pack.files[j].name);
            if (pack.files[j].name[namelen - 4] == '.' && pack.files[j].name[namelen - 3] == 'b' && pack.files[j].name[namelen - 2] == 's' && pack.files[j].name[namelen - 1] == 'p')
            {
                int p = namelen - 1;
                while (p >= 0)
                {
                    if (pack.files[j].name[p] == '/')
                    {
                        break;
                    }
                    p--;
                }
                char tempfilename[MAX_OSPATH];
                strcpy(tempfilename, "/tmp/leechwad.");
                sprintf(tempfilename, "/tmp/leechwad.%i.%s", (int)fortemp, pack.files[j].name + p + 1);
                struct stat filestatus;
                if (stat(tempfilename, &filestatus) != 0)
                {
                    Sys_FileSeek(packhandle, pack.files[j].filepos);
                    unsigned char* bsp = malloc(pack.files[j].filelen);
                    Sys_FileRead(packhandle, bsp, pack.files[j].filelen);
                    int tempfile = -1;
                    if ((tempfile = Sys_FileOpenWrite (tempfilename)) == -1)
                    {
                        printf ("Couldn't create %s\n", tempfilename);
                        return EXIT_FAILURE;
                    }
                    Sys_FileWrite(tempfile, bsp, pack.files[j].filelen);
                    Sys_FileClose(tempfile);
                }
                LoadBSPFile(tempfilename);
                if (texdatasize > 0)
                {
                    dmiptexlump_t* mtl = (dmiptexlump_t *)dtexdata;
                    int c = LittleLong(mtl->nummiptex);
                    mtl->nummiptex = LittleLong (mtl->nummiptex);
                    for (int k = 0; k < c; k++)
                    {
                        mtl->dataofs[k] = LittleLong(mtl->dataofs[k]);
                        miptex_t* mt = (miptex_t *)((byte *)mtl + mtl->dataofs[k]);
                        if (!strcasecmp(mt->name, miptex->name))
                        {
                            int width = LittleLong (mt->width);
                            int height = LittleLong (mt->height);
                            int pixels = width * height / 64 * 85;
                            W_AddLump(miptex->name, mt, sizeof(miptex_t) + pixels, TYP_LUMPY + 3, false);
                            found = true;
                            break;
                        }
                    }
                    if (found)
                    {
                        break;
                    }
                }
            }
        }
        if (found)
        {
            continue;
        }
        unsigned char band = rand() % 15;
        unsigned char outer = band * 16 + (rand() % 16);
        unsigned char ul = band * 16 + (rand() % 16);
        unsigned char ur = band * 16 + (rand() % 16);
        unsigned char lr = band * 16 + (rand() % 16);
        unsigned char ll = band * 16 + (rand() % 16);
        unsigned char* pixel = lump + miptex->offsets[0];
        int size = 64;
        unsigned char* previous = pixel;
        for (int j = 0; j < size; j++)
        {
            for (int k = 0; k < size; k++)
            {
                if (j >= 16 && j < 32 && k >= 16 && k < 32)
                {
                    *pixel = ul;
                }
                else if (j >= 32 && j < 48 && k >= 16 && k < 32)
                {
                    *pixel = ur;
                }
                else if (j >= 32 && j < 48 && k >= 32 && k < 48)
                {
                    *pixel = lr;
                }
                else if (j >= 16 && j < 32 && k >= 32 && k < 48)
                {
                    *pixel = ll;
                }
                else
                {
                    *pixel = outer;
                }
                pixel++;
            }
        }
        for (int offset = 1; offset < 4; offset++)
        {
            unsigned char* start = pixel;
            for (int j = 0; j < size; j += 2)
            {
                for (int k = 0; k < size; k += 2)
                {
                    *pixel = previous[j * size + k];
                    pixel++;
                }
            }
            size /= 2;
            previous = start;
        }
        W_AddLump(miptex->name, lump, lumpsize, TYP_LUMPY + 3, false);
    };
    W_WriteWad();
    for (int i = 0; i < pack.numfiles; i++)
    {
        int namelen = strlen(pack.files[i].name);
        if (pack.files[i].name[namelen - 4] == '.' && pack.files[i].name[namelen - 3] == 'b' && pack.files[i].name[namelen - 2] == 's' && pack.files[i].name[namelen - 1] == 'p')
        {
            int p = namelen - 1;
            while (p >= 0)
            {
                if (pack.files[i].name[p] == '/')
                {
                    break;
                }
                p--;
            }
            char tempfilename[MAX_OSPATH];
            strcpy(tempfilename, "/tmp/leechwad.");
            sprintf(tempfilename, "/tmp/leechwad.%i.%s", (int)fortemp, pack.files[i].name + p + 1);
            remove(tempfilename);
        }
    }
    return EXIT_SUCCESS;
}
