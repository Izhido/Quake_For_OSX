#import <Scroller.h>

#define NX_BEZEL NSBezelBorder

#define NX_WIDTHSIZABLE NSViewWidthSizable
#define NX_HEIGHTSIZABLE NSViewHeightSizable

@interface ScrollView : NSScrollView
{
    Scroller* hScroller;
    Scroller* vScroller;
}

-(void)setHorizScrollerRequired:(BOOL)required;

-(void)setVertScrollerRequired:(BOOL)required;

-(Scroller*)horizScroller;

-(Scroller*)vertScroller;

-(id)setDocView:(id)view;

-(void)setAutosizing:(int)mask;

@end
