#import <Button.h>

@implementation Button

-(void)getFrame:(NXRect*)frame
{
    NSRect rect = self.frame;
    frame->origin = rect.origin;
    frame->size = rect.size;
}

@end
