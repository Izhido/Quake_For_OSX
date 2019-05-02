#import <Cocoa/Cocoa.h>
#import <NXRect.h>

@interface Scroller : NSObject

-(instancetype)initWithScroller:(NSScroller*)scroller;

-(void)getFrame:(NXRect*)frame;

-(void)setFrame:(NXRect*)frame;

@end
