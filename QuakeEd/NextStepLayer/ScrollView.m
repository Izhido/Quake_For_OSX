#import <ScrollView.h>

@implementation ScrollView

-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self != nil)
    {
        hScroller = [[Scroller alloc] initWithScrollView:self isVertical:NO];
        vScroller = [[Scroller alloc] initWithScrollView:self isVertical:YES];
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

-(Scroller*)horizScroller
{
    return hScroller;
}

-(Scroller*)vertScroller
{
    return vScroller;
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

+(BOOL)isCompatibleWithOverlayScrollers
{
    return NO;
}

@end
