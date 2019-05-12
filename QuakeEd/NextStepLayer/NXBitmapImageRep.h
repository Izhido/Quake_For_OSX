#import <AppKit/AppKit.h>

@interface NXBitmapImageRep : NSBitmapImageRep

-(instancetype)initData:(unsigned char *)data pixelsWide:(int)width pixelsHigh:(int)height bitsPerSample:(int)bps samplesPerPixel:(int)spp hasAlpha:(BOOL)alpha isPlanar:(BOOL)config colorSpace:(NSString*)space bytesPerRow:(int)rowBytes bitsPerPixel:(int)pixelBits;

-(id)free;

@end
