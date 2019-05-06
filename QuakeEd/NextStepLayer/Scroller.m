#import <Scroller.h>

@implementation Scroller
{
    NSScrollView* scrollView;
    BOOL isVertical;
}

-(instancetype)initWithScrollView:(NSScrollView*)scrollView isVertical:(BOOL)isVertical
{
    self = [super init];
    if (self != nil)
    {
        self->scrollView = scrollView;
        self->isVertical = isVertical;
    }
    return self;
}

-(NSScroller*)scrollerReference
{
    if (isVertical)
    {
        return scrollView.verticalScroller;
    }
    return scrollView.horizontalScroller;
}

-(void)getFrame:(NXRect*)frame
{
    NSScroller* scroller = self.scrollerReference;
    frame->origin = scroller.frame.origin;
    frame->size = scroller.frame.size;
}

-(void)setFrame:(NXRect*)frame
{
    NSScroller* scroller = self.scrollerReference;
    scroller.frame = *frame;
}

-(void)display
{
    NSScroller* scroller = self.scrollerReference;
    [scroller display];
}

@end
