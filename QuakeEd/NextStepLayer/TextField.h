#import <AppKit/AppKit.h>

@interface TextField : NSTextField

@property (nonatomic, assign) const char* stringValueAsString;

-(void)selectAll:(id)sender;

-(void)replaceSel:(const char*)string;

@end
