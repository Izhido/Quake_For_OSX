#import "AppDelegate.h"
#import "qedefs.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [(QuakeEd*)self.window appDidInit:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [(QuakeEd*)self.window appWillTerminate:self];
}

-(void)postApplicationDefinedEvent
{
    [self performSelectorOnMainThread:@selector(applicationDefined) withObject:nil waitUntilDone:NO];
}

-(void)applicationDefined
{
    [(QuakeEd*)self.window applicationDefined:nil];
}

@end
