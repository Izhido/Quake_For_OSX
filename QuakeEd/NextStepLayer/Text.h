#import <Cocoa/Cocoa.h>

@interface Text : NSTextView

-(int)textLength;

-(void)setSel:(int)start :(int)end;

-(void)replaceSel:(const char*)string;

-(void)scrollSelToVisible;

-(void)printPSCode:(NSObject*)sender;

@end
