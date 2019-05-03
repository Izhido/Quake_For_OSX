#import <AppKit/AppKit.h>

@interface Matrix : NSView

-(void)addViewAtRow:(int)row column:(int)column view:(NSView*)view;

-(id)cellAt:(int)row :(int)column;

-(void)selectCellAt:(int)row :(int)column;

@end
