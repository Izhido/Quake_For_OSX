#import <Object.h>

@implementation Object

-(id)copyFromZone:(NXZone*)zone
{
    return [[self.class allocWithZone:zone] init];
}

-(id)copyWithZone:(NSZone*)zone
{
    return [self copyFromZone:zone];
}

-(void)freeObjects
{
}

-(id)free
{
    return nil;
}

@end

char latestDefaultValue[4096];

char* NXGetDefaultValue(const char* owner, const char* key)
{
    NSString* value = [NSUserDefaults.standardUserDefaults stringForKey:[NSString stringWithCString:key encoding:NSString.defaultCStringEncoding]];
    strncpy(latestDefaultValue, [value cStringUsingEncoding:NSString.defaultCStringEncoding], 4096);
    return latestDefaultValue;
}

void NXWriteDefault(const char* owner, const char* key, const char* value)
{
    [NSUserDefaults.standardUserDefaults setObject:[NSString stringWithCString:value encoding:NSString.defaultCStringEncoding] forKey:[NSString stringWithCString:key encoding:NSString.defaultCStringEncoding]];
}
