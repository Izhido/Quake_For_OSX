#import <OpenPanel.h>
#import <AppKit/AppKit.h>

@implementation OpenPanel
{
    NSOpenPanel* openPanel;
    char** filenamesAsStringList;
    int filenamesAsStringListCount;
    char* directoryAsString;
}

-(instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        openPanel = [NSOpenPanel new];
        filenamesAsStringList = nil;
        filenamesAsStringListCount = 0;
        directoryAsString = nil;
    }
    return self;
}

-(void)allowMultipleFiles:(BOOL)allow
{
    openPanel.allowsMultipleSelection = allow;
}

-(void)chooseDirectories:(BOOL)choose
{
    openPanel.canChooseDirectories = choose;
}

-(int)runModalForDirectoryAsString:(const char*)path file:(const char*)file types:(const char**)types
{
    NSMutableArray<NSString*>* typesAsArray = [NSMutableArray<NSString*> new];
    int i = 0;
    while(types[i] != nil)
    {
        [typesAsArray addObject:[NSString stringWithCString:types[i] encoding:NSString.defaultCStringEncoding]];
        i++;
    }
    return [openPanel runModalForDirectory:[NSString stringWithCString:path encoding:NSString.defaultCStringEncoding] file:[NSString stringWithCString:file encoding:NSString.defaultCStringEncoding] types:typesAsArray];
}

-(int)runModalForTypesAsStringList:(char**)types
{
    NSMutableArray<NSString*>* typesAsArray = [NSMutableArray<NSString*> new];
    int i = 0;
    while(types[i] != nil)
    {
        [typesAsArray addObject:[NSString stringWithCString:types[i] encoding:NSString.defaultCStringEncoding]];
        i++;
    }
    return [openPanel runModalForTypes:typesAsArray];
}

-(void)releaseFilenamesAsStringList
{
    if (filenamesAsStringListCount > 0)
    {
        while (filenamesAsStringListCount > 0)
        {
            filenamesAsStringListCount--;
            free(filenamesAsStringList[filenamesAsStringListCount]);
        }
        free(filenamesAsStringList);
    }
}

-(char**)filenamesAsStringList
{
    [self releaseFilenamesAsStringList];
    NSString* directory = openPanel.directoryURL.path;
    if ([directory characterAtIndex:directory.length - 1] == '/')
    {
        directory = [directory substringToIndex:directory.length - 1];
    }
    filenamesAsStringListCount = (int)openPanel.URLs.count;
    filenamesAsStringList = malloc(sizeof(char*) * (filenamesAsStringListCount + 1));
    for (int i = 0; i < filenamesAsStringListCount; i++)
    {
        NSString* filename = openPanel.URLs[i].path;
        filename = [filename substringFromIndex:directory.length];
        if ([filename characterAtIndex:0] == '/')
        {
            filename = [filename substringFromIndex:1];
        }
        filenamesAsStringList[i] = malloc(filename.length + 1);
        strcpy(filenamesAsStringList[i], [filename cStringUsingEncoding:NSString.defaultCStringEncoding]);
    }
    filenamesAsStringList[filenamesAsStringListCount] = nil;
    return filenamesAsStringList;
}

-(void)releaseDirectoryAsString
{
    if (directoryAsString != nil)
    {
        free(directoryAsString);
    }
}

-(char*)directoryAsString
{
    [self releaseDirectoryAsString];
    NSString* directory = openPanel.directoryURL.path;
    if ([directory characterAtIndex:directory.length - 1] == '/')
    {
        directory = [directory substringToIndex:directory.length - 1];
    }
    directoryAsString = malloc(directory.length + 1);
    strcpy(directoryAsString, [directory cStringUsingEncoding:NSString.defaultCStringEncoding]);
    return directoryAsString;
}

- (void)dealloc
{
    [self releaseFilenamesAsStringList];
    [self releaseDirectoryAsString];
}

@end
