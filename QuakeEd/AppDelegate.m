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

@end
