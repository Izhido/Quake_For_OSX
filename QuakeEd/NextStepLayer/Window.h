#import <AppKit/AppKit.h>
#import <NXRect.h>

#define NX_RETAINED NSBackingStoreRetained

#define NX_BUFFERED NSBackingStoreBuffered

@interface Window : NSWindow

- initContent:(const NXRect *)contentRect style:(int)aStyle backing:(int)backingType buttonMask:(int)mask defer:(BOOL)flag;

-(void)reenableFlushWindow;

-(void)setTitleAsFilename:(const char*)filename;

-(void)applicationDefined:(NXEvent*)event;

@end

int DPSPostEvent(NXEvent* event, int atStart);

void DPSDoUserPath(float* points, int numberOfPoints, int dataType, char* ops, int numberOfOps, float* bbox, int opForUserPath);
