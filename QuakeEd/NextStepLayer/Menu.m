#import <Menu.h>

@implementation Menu
{
    NSPopUpButton* button;
}

-(instancetype)initWithPopUpButton:(NSPopUpButton*)button
{
    self = [super init];
    if (self != nil)
    {
        self->button = button;
    }
    return self;
}

-(void)selectCellAt:(int)row :(int)column
{
    [button selectItemAtIndex:row];
}

@end
