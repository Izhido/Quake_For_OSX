#import <Text.h>

@implementation Text

-(const char*)stringValueAsString
{
    return [self.string cStringUsingEncoding:NSString.defaultCStringEncoding];
}

-(void)setStringValueAsString:(const char*)value
{
    self.string = [NSString stringWithCString:value encoding:NSString.defaultCStringEncoding];
}

-(int)textLength
{
    return (int)self.string.length;
}

-(void)setSel:(int)start :(int)end
{
    NSRange range = NSMakeRange(start, end - start);
    self.selectedRange = range;
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
