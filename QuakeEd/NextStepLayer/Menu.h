#import <AppKit/AppKit.h>

@interface Menu : NSObject

-(instancetype)initWithPopUpButton:(NSPopUpButton*)button;

-(void)selectCellAt:(int)row :(int)column;

@end
