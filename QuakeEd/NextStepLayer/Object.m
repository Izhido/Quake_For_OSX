#import <Object.h>

@implementation Object

-(id)copyFromZone:(NXZone*)zone
{
    return nil;
}

-(void)freeObjects
{
}

-(id)free
{
    return nil;
}

@end

char* NXGetDefaultValue(const char* owner, const char* key)
{
    NSString* value = [NSUserDefaults.standardUserDefaults stringForKey:[NSString stringWithCString:key encoding:NSString.defaultCStringEncoding]];
    return [value cStringUsingEncoding:NSString.defaultCStringEncoding];
}

void NXWriteDefault(const char* owner, const char* key, const char* value)
{
    [NSUserDefaults.standardUserDefaults setObject:[NSString stringWithCString:value encoding:NSString.defaultCStringEncoding] forKey:[NSString stringWithCString:key encoding:NSString.defaultCStringEncoding]];
}
