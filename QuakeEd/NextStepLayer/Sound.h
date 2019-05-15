#import <Foundation/Foundation.h>

@interface Sound : NSObject

-(instancetype)initFromSoundfile:(const char*)filename;

-(id)free;

@end
