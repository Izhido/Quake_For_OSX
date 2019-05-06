#import <PopUpList.h>
#import <Menu.h>

@implementation PopUpList

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _items = [NSMutableArray<NSString*> new];
    }
    return self;
}

-(void)addItem:(const char*)item
{
    [self.items addObject:[NSString stringWithCString:item encoding:NSString.defaultCStringEncoding]];
}

-(Menu*)itemList
{
    return [[Menu alloc] initWithPopUpList:self];;
}

-(void)menuItemSelected:(id)sender
{
    if ([self.target respondsToSelector:self.action])
    {
        [self.target performSelector:self.action withObject:self.button];
    }
}

@end

Button* NXCreatePopUpListButton(PopUpList* list)
{
    Button* button = [[Button alloc] initWithFrame:NSMakeRect(0,0,80,20) pullsDown:NO];
    for (NSString* item in list.items)
    {
        [button addItemWithTitle:item];
    }
    button.target = list;
    button.action = @selector(menuItemSelected:);
    [button selectItemAtIndex:list.selection];
    list.button = button;
    return button;
}
