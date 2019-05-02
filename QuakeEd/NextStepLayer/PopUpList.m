#import "PopUpList.h"

@implementation PopUpList
{
    Menu* menu;
}

-(void)addItem:(const char*)item
{
    [self addItemWithTitle:[NSString stringWithCString:item encoding:NSString.defaultCStringEncoding]];
}

-(Menu*)itemList
{
    if (menu == nil)
    {
        menu = [[Menu alloc] initWithPopUpButton:self];
    }
    return menu;
}

@end

NSPopUpButton* NXCreatePopUpListButton(PopUpList* list)
{
    return list;
}
