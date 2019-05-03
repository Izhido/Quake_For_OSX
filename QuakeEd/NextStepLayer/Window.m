#import <Window.h>
#import "AppDelegate.h"
#import <dpsclient/dpsclient.h>
#import <View.h>

@implementation Window

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag
{
    self = [self initContent:&contentRect style:style backing:backingStoreType buttonMask:0 defer:flag];
    return self;
}

- initContent:(const NXRect *)contentRect style:(int)aStyle backing:(int)backingType buttonMask:(int)mask defer:(BOOL)flag
{
    return [super initWithContentRect:*contentRect styleMask:aStyle backing:backingType defer:flag];
}

-(void)reenableFlushWindow
{
    [self enableFlushWindow];
}

-(void)setTitleAsFilename:(const char*)filename
{
    [self setTitleWithRepresentedFilename:[NSString stringWithCString:filename encoding:NSString.defaultCStringEncoding]];
}

-(void)applicationDefined
{
}

@end

int DPSPostEvent(NXEvent* event, int atStart)
{
    if (event->type == NX_APPDEFINED)
    {
        [((AppDelegate*)NSApp.delegate) postApplicationDefinedEvent];
    }
    return 0;
}

void DPSDoUserPath(float* points, int numberOfPoints, int dataType, char* ops, int numberOfOps, float* bbox, int opForUserPath)
{
    int position = 0;
    for (int i = 0; i < numberOfOps; i++)
    {
        if (ops[i] == dps_moveto)
        {
            PSmoveto(points[position], points[position + 1]);
            position += 2;
        }
        else if (ops[i] == dps_lineto)
        {
            PSlineto(points[position], points[position + 1]);
            position += 2;
        }
    }
    PSstroke();
}
