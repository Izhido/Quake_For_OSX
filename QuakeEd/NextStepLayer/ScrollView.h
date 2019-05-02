#import <Cocoa/Cocoa.h>
#import <Scroller.h>

#define NX_BEZEL NSBezelBorder

#define NX_WIDTHSIZABLE NSViewWidthSizable
#define NX_HEIGHTSIZABLE NSViewHeightSizable

@interface ScrollView : NSScrollView
{
    Scroller* hScroller;
    Scroller* vScroller;
}

-(instancetype)initFrame:(const NXRect*)frame;

-(void)setHorizScrollerRequired:(BOOL)required;

-(void)setVertScrollerRequired:(BOOL)required;

-(id)setDocView:(id)view;

-(void)setAutosizing:(int)mask;

@end
