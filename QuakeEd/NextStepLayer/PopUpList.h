#import <Menu.h>
#import <NXRect.h>

@interface PopUpList : NSPopUpButton

-(void)getFrame:(NXRect*)frame;

-(void)addItem:(const char*)item;

-(Menu*)itemList;

@end

NSPopUpButton* NXCreatePopUpListButton(PopUpList* list);
