#import <Text.h>

@implementation Text

-(int)textLength
{
    return (int)self.string.length;
}

-(void)setSel:(int)start :(int)end
{
    NSRange range = NSMakeRange(start, end - start);
    self.selectedRange = range;
}

-(void)replaceSel:(const char*)string
{
    [self replaceCharactersInRange:self.selectedRange withString:[NSString stringWithCString:string encoding:NSString.defaultCStringEncoding]];
}

-(void)scrollSelToVisible
{
    [self scrollRangeToVisible:self.selectedRange];
}

-(void)printPSCode:(NSObject*)sender
{
    [self print:sender];
}

@end
