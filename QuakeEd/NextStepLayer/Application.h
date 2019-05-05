#import <AppKit/AppKit.h>
#import <NXScreen.h>

@interface Application : NSObject

-(void)getScreens:(NXScreen**)screens count:(int*)count;

-(NXEvent*)peekNextEvent:(int)mask into:(NXEvent*)event;

-(NSEvent*)getNextEvent:(int)mask;

-(void)terminate:(id)sender;

@end

extern Application* NXApp;
