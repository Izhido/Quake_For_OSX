#import <AppKit/AppKit.h>

@interface Matrix : NSView

-(void)setTarget:(id)target;

-(void)setAction:(SEL)action;

-(int)selectedCol;

-(id)cellAt:(int)row :(int)column;

-(void)selectCellAt:(int)row :(int)column;

@end
