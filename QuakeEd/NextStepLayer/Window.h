#import <Cocoa/Cocoa.h>
#import <NXRect.h>

#define NX_RETAINED NSBackingStoreRetained

#define NX_BUFFERED NSBackingStoreBuffered

@interface Window : NSWindow

- initContent:(const NXRect *)contentRect style:(int)aStyle backing:(int)backingType buttonMask:(int)mask defer:(BOOL)flag;

-(void)reenableFlushWindow;

@end
