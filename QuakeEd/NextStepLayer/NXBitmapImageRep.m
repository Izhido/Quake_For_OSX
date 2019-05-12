#import <NXBitmapImageRep.h>

@implementation NXBitmapImageRep

-(instancetype)initData:(unsigned char *)data pixelsWide:(int)width pixelsHigh:(int)height bitsPerSample:(int)bps samplesPerPixel:(int)spp hasAlpha:(BOOL)alpha isPlanar:(BOOL)config colorSpace:(NSString*)space bytesPerRow:(int)rowBytes bitsPerPixel:(int)pixelBits
{
    return [self initWithBitmapDataPlanes:&data pixelsWide:width pixelsHigh:height bitsPerSample:bps samplesPerPixel:spp hasAlpha:alpha isPlanar:config colorSpaceName:space bitmapFormat:NSBitmapFormatThirtyTwoBitLittleEndian bytesPerRow:rowBytes bitsPerPixel:pixelBits];
}

-(id)free
{
    return self;
}

@end
