#import <AppKit/AppKit.h>

@interface Text : NSTextView

@property (nonatomic, assign) const char* stringValueAsString;

-(int)textLength;

-(void)setSel:(int)start :(int)end;

-(void)scrollSelToVisible;

-(void)printPSCode:(NSObject*)sender;

@end
