#import <SavePanel.h>
#import <AppKit/AppKit.h>

@implementation SavePanel
{
    NSSavePanel* savePanel;
    char* filenameAsString;
}

-(instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        savePanel = [NSSavePanel new];
        filenameAsString = nil;
    }
    return self;
}

-(void)setRequiredFileType:(const char*)type
{
    savePanel.requiredFileType = [NSString stringWithCString:type encoding:NSString.defaultCStringEncoding];
}

-(void)releaseFilenameAsString
{
    if (filenameAsString != nil)
    {
        free(filenameAsString);
    }
}

-(int)runModalForDirectoryAsString:(const char*)path file:(const char*)file
{
    return [savePanel runModalForDirectory:[NSString stringWithCString:path encoding:NSString.defaultCStringEncoding] file:[NSString stringWithCString:file encoding:NSString.defaultCStringEncoding]];
}

-(char*)filenameAsString
{
    [self releaseFilenameAsString];
    NSString* filename = savePanel.URL.path;
    filenameAsString = malloc(filename.length + 1);
    strcpy(filenameAsString, [filename cStringUsingEncoding:NSString.defaultCStringEncoding]);
    return filenameAsString;
}

-(void)dealloc
{
    [self releaseFilenameAsString];
}

@end
