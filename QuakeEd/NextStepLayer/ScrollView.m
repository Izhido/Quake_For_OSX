#import "ScrollView.h"

@implementation ScrollView

-(instancetype)initFrame:(const NXRect*)frame
{
    self = [super initWithFrame:*frame];
    if (self != nil)
    {
        hScroller = [[Scroller alloc] initWithScroller:self.horizontalScroller];
        vScroller = [[Scroller alloc] initWithScroller:self.verticalScroller];
    }
    return self;
}

-(void)setHorizScrollerRequired:(BOOL)required
{
    self.hasHorizontalScroller = required;
}

-(void)setVertScrollerRequired:(BOOL)required
{
    self.hasVerticalScroller = required;
}

-(id)setDocView:(id)view
{
    self.documentView = view;
    return nil;
}

-(void)setAutosizing:(int)mask
{
    self.autoresizingMask = mask;
}

@end
