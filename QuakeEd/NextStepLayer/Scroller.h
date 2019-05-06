#import <AppKit/AppKit.h>
#import <NXRect.h>

@interface Scroller : NSObject

-(instancetype)initWithScrollView:(NSScrollView*)scrollView isVertical:(BOOL)isVertical;

-(void)getFrame:(NXRect*)frame;

-(void)setFrame:(NXRect*)frame;

-(void)display;

@end
