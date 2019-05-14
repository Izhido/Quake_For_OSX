#import <TextField.h>

@implementation TextField

-(const char*)stringValueAsString
{
    return [self.stringValue cStringUsingEncoding:NSString.defaultCStringEncoding];
}

-(void)setStringValueAsString:(const char*)value
{
    if (value == nil)
    {
        self.stringValue = @"";
    }
    else
    {
        self.stringValue = [NSString stringWithCString:value encoding:NSString.defaultCStringEncoding];
    }
}

-(void)selectAll:(id)sender
{
    [self selectText:sender];
}

-(void)replaceSel:(const char*)string
{
    
    [self setStringValueAsString:string];
}

@end
