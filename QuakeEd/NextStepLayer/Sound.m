#import <Sound.h>
#import <AppKit/AppKit.h>

@implementation Sound
{
    NSSound* sound;
}

-(instancetype)initFromSoundfile:(const char*)filename
{
    NSSound* sound = [[NSSound alloc] initWithContentsOfFile:[NSString stringWithCString:filename encoding:NSString.defaultCStringEncoding] byReference:YES];
    if (sound != nil)
    {
        self = [super init];
        if (self != nil)
        {
            self->sound = sound;
        }
        return self;
    }
    else
    {
        return nil;
    }
}

-(void)play
{
    [sound play];
}

-(id)free
{
    return self;
}

@end
