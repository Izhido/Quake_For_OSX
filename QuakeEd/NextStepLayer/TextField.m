#import <TextField.h>

@implementation TextField

-(const char*)stringValueAsString
{
    return [self.stringValue cStringUsingEncoding:NSString.defaultCStringEncoding];
}

-(void)setStringValueAsString:(const char*)value
{
    self.stringValue = [NSString stringWithCString:value encoding:NSString.defaultCStringEncoding];
}

@end
