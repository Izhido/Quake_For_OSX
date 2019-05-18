#import <AppKit/AppKit.h>

@interface Text : NSTextView

@property (nonatomic, assign) const char* stringValueAsString;

-(int)textLength;

-(void)setSel:(int)start :(int)end;

-(void)replaceSel:(const char*)string;

-(void)scrollSelToVisible;

-(void)printPSCode:(NSObject*)sender;

@end
