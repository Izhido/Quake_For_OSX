#import <Menu.h>
#import <PopUpList.h>

@implementation Menu
{
    PopUpList* list;
}

-(instancetype)initWithPopUpList:(PopUpList*)list
{
    self = [super init];
    if (self != nil)
    {
        self->list = list;
    }
    return self;
}

-(void)selectCellAt:(int)row :(int)column
{
    list.selection = row;
}

@end
