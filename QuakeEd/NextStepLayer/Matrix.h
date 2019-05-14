#import <AppKit/AppKit.h>

@interface Matrix : NSView

@property (nonatomic, assign) int rowCount;

-(void)setTarget:(id)target;

-(void)setAction:(SEL)action;

-(int)selectedCol;

-(id)cellAt:(int)row :(int)column;

-(void)selectCellAt:(int)row :(int)column;

@end
