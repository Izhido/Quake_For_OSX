#import <Foundation/Foundation.h>

@interface Sound : NSObject

-(instancetype)initFromSoundfile:(const char*)filename;

-(BOOL)play;

-(id)free;

@end
