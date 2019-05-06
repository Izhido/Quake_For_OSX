#import <AppKit/AppKit.h>
#import <Button.h>

@class Menu;

@interface PopUpList : NSObject

@property (nonatomic, readonly) NSMutableArray<NSString*>* items;

@property (nonatomic, strong) id target;

@property (nonatomic, assign) SEL action;

@property (nonatomic, assign) int selection;

@property (nonatomic, strong) Button* button;

-(void)addItem:(const char*)item;

-(Menu*)itemList;

@end

Button* NXCreatePopUpListButton(PopUpList* list);
