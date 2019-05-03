#import <Scroller.h>

@implementation Scroller
{
    NSScroller* scroller;
}

-(instancetype)initWithScroller:(NSScroller*)scroller
{
    self = [super init];
    if (self != nil)
    {
        self->scroller = scroller;
    }
    return self;
}

-(void)getFrame:(NXRect*)frame
{
    *frame = scroller.frame;
}

-(void)setFrame:(NXRect*)frame
{
    scroller.frame = *frame;
}

@end
