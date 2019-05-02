#import <NXZone.h>

@interface Object : NSObject

-(id)copyFromZone:(NXZone*)zone;

-(void)freeObjects;

-(id)free;

@end

char* NXGetDefaultValue(const char* owner, const char* key);

void NXWriteDefault(const char* owner, const char* key, const char* value);
