#import "Application.h"

@implementation Application
{
    NXScreen* screens;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        screens = nil;
    }
    return self;
}

-(void)releaseScreens
{
    if (screens != nil)
    {
        free(screens);
    }
}

-(void)getScreens:(NXScreen**)screens count:(int*)count
{
    [self releaseScreens];
    self->screens = malloc(NSScreen.screens.count * sizeof(NXScreen));
    for (int i = 0; i < NSScreen.screens.count; i++)
    {
        self->screens[i].screen = NSScreen.screens[i];
        self->screens[i].screenBounds = NSScreen.screens[i].frame;
    }
    *screens = self->screens;
    int countToReturn = NSScreen.screens.count;
    *count = countToReturn;
}

-(NXEvent*)peekNextEvent:(int)mask into:(NXEvent*)event
{
    return nil;
}

-(NSEvent*)getNextEvent:(int)mask
{
    return [NSApplication.sharedApplication nextEventMatchingMask:mask untilDate:NSDate.distantFuture inMode:NSEventTrackingRunLoopMode dequeue:YES];
}

-(void)terminate:(id)sender
{
    [NSApplication.sharedApplication terminate:sender];
}

- (void)dealloc
{
    [self releaseScreens];
}
@end

Application* NXApp = nil;
