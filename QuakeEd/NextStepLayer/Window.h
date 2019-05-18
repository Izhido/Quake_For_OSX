#import <AppKit/AppKit.h>
#import <NXRect.h>
#import <NXScreen.h>

#define NX_RETAINED NSBackingStoreRetained

#define NX_BUFFERED NSBackingStoreBuffered

#define DPSTimedEntry NSTimer*

#define NX_BASETHRESHOLD 0

@interface Window : NSWindow

- initContent:(const NXRect *)contentRect style:(int)aStyle backing:(int)backingType buttonMask:(int)mask defer:(BOOL)flag;

-(void)reenableFlushWindow;

-(void)disableDisplay;

-(void)reenableDisplay;

-(void)setTitleAsFilename:(const char*)filename;

-(void)applicationDefined:(NXEvent*)event;

-(void)moveTopLeftTo:(int)x :(int)y screen:(const NXScreen*)screen;

@end

int DPSPostEvent(NXEvent* event, int atStart);

void DPSDoUserPath(float* points, int numberOfPoints, int dataType, char* ops, int numberOfOps, float* bbox, int opForUserPath);

typedef void (*DPSTimedEntryProc)(DPSTimedEntry tag, double now, void *userData);

DPSTimedEntry DPSAddTimedEntry(double period, DPSTimedEntryProc handler, id userData, int priority);

void DPSRemoveTimedEntry(DPSTimedEntry tag);
