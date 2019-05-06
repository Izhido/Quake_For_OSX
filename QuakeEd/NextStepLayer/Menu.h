#import <Foundation/Foundation.h>

@class PopUpList;

@interface Menu : NSObject

-(instancetype)initWithPopUpList:(PopUpList*)list;

-(void)selectCellAt:(int)row :(int)column;

@end
