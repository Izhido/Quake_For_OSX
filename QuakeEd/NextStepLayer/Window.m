#import "Window.h"

@implementation Window

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag
{
    self = [self initContent:&contentRect style:style backing:backingStoreType buttonMask:0 defer:flag];
    return self;
}

- initContent:(const NXRect *)contentRect style:(int)aStyle backing:(int)backingType buttonMask:(int)mask defer:(BOOL)flag
{
    return [super initWithContentRect:*contentRect styleMask:aStyle backing:backingType defer:flag];
}

-(void)reenableFlushWindow
{
    [self enableFlushWindow];
}

-(void)setTitleAsFilename:(const char*)filename
{
    [self setTitleWithRepresentedFilename:[NSString stringWithCString:filename encoding:NSString.defaultCStringEncoding]];
}
@end
