#import <Menu.h>

@interface PopUpList : NSPopUpButton

-(void)addItem:(const char*)item;

-(Menu*)itemList;

@end

NSPopUpButton* NXCreatePopUpListButton(PopUpList* list);
