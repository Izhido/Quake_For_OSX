#import <View.h>

@implementation View

-(instancetype)initFrame:(const NXRect*)frame
{
    return [super initWithFrame:*frame];
}

-(void)getBounds:(NXRect*)bounds
{
    bounds->origin = self.bounds.origin;
    bounds->size = self.bounds.size;
}

-(void)getVisibleRect:(NXRect*)visibleRect
{
    visibleRect->origin = self.visibleRect.origin;
    visibleRect->size = self.visibleRect.size;
}

-(void)sizeTo:(int)width :(int)height
{
    NSRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = height;
    self.frame = frame;
}

-(void)scrollPointAsNXPoint:(NXPoint*)point
{
    NSPoint pointAsPoint = NSMakePoint(point->x, point->y);
    [super scrollPoint:pointAsPoint];
}

-(void)scrollRectToVisibleAsNXRect:(const NXRect *)rect
{
    [super scrollRectToVisible:*rect];
}

-(void)setAutoresizeSubviews:(BOOL)autoresizeSubviews
{
    self.autoresizesSubviews = autoresizeSubviews;
}

@end

void NXDrawBitmap(NXRect* rect, int width, int height, int bps, int spp, int bpp, int bpr, BOOL isPlanar, BOOL hasAlpha, NSColorSpaceName colorSpaceName, const char* planes)
{
    NSDrawBitmap(*rect, width, height, bps, spp, bpp, bpr, isPlanar, hasAlpha, colorSpaceName, planes);
}

void NXEraseRect(NXRect* rect)
{
    NSEraseRect(*rect);
}

int NXGrayComponent(int gray)
{
    return gray;
}

void NXRectClip(NXRect* rect)
{
    NSRectClip(*rect);
}

void NXRectFill(NXRect* rect)
{
    NSRectFill(*rect);
}

int NXRunAlertPanel(const char* title, const char* msgFormat, const char* defaultButton, const char* alternateButton, const char* otherButton)
{
    NSString* titleAsString = nil;
    if ( title != nil)
    {
         titleAsString = [NSString stringWithCString:title encoding:NSString.defaultCStringEncoding];
    }
    NSString* msgFormatAsString = nil;
    if (msgFormat != nil)
    {
        msgFormatAsString = [NSString stringWithCString:msgFormat encoding:NSString.defaultCStringEncoding];
    }
    NSString* defaultButtonAsString = nil;
    if (defaultButton != nil)
    {
        defaultButtonAsString = [NSString stringWithCString:defaultButton encoding:NSString.defaultCStringEncoding];
    }
    NSString* alternateButtonAsString = nil;
    if (alternateButton != nil)
    {
        alternateButtonAsString = [NSString stringWithCString:alternateButton encoding:NSString.defaultCStringEncoding];
    }
    NSString* otherButtonAsString = nil;
    if (otherButton != nil)
    {
        otherButtonAsString = [NSString stringWithCString:otherButton encoding:NSString.defaultCStringEncoding];
    }
    return NSRunAlertPanel(titleAsString, msgFormatAsString, defaultButtonAsString, alternateButtonAsString, otherButtonAsString);
}

CGContextRef currentContextForPSFunctions = nil;
float currentXForPSFunctions = 0;
float currentYForPSFunctions = 0;

void PSusecontext(CGContextRef context)
{
    currentContextForPSFunctions = context;
    currentXForPSFunctions = 0;
    currentYForPSFunctions = 0;
}

void PSarc(float x, float y, float radius, float startAngle, float endAngle)
{
    CGContextAddArc(currentContextForPSFunctions, x, y, radius, startAngle, endAngle, NO);
    currentXForPSFunctions = x;
    currentYForPSFunctions = y;
}

void PSfill()
{
    CGContextFillPath(currentContextForPSFunctions);
}

void PSlineto(float x, float y)
{
    CGContextAddLineToPoint(currentContextForPSFunctions, x, y);
    currentXForPSFunctions = x;
    currentYForPSFunctions = y;
}

void PSmoveto(float x, float y)
{
    CGContextMoveToPoint(currentContextForPSFunctions, x, y);
    currentXForPSFunctions = x;
    currentYForPSFunctions = y;
}

void PSrectfill(float x, float y, float width, float height)
{
    CGContextFillRect(currentContextForPSFunctions, NSMakeRect(x, y, width, height));
    currentXForPSFunctions = x + width;
    currentYForPSFunctions = y + height;
}

void PSrectstroke(float x, float y, float width, float height)
{
    CGContextStrokeRect(currentContextForPSFunctions, NSMakeRect(x, y, width, height));
    currentXForPSFunctions = x + width;
    currentYForPSFunctions = y + height;
}

void PSrlineto(float x, float y)
{
    CGContextAddLineToPoint(currentContextForPSFunctions, currentXForPSFunctions + x, currentYForPSFunctions + y);
    currentXForPSFunctions += x;
    currentYForPSFunctions += y;
}

void PSrotate(float angle)
{
    CGContextRotateCTM(currentContextForPSFunctions, angle);
}

void PSselectfont(const char* name, float size)
{
    CGContextSelectFont(currentContextForPSFunctions, name, size, kCGEncodingFontSpecific);
}

void PSsetgray(float gray)
{
    CGContextSetGrayStrokeColor(currentContextForPSFunctions, gray, 1);
    CGContextSetGrayFillColor(currentContextForPSFunctions, gray, 1);
}

void PSsetlinewidth(float width)
{
    CGContextSetLineWidth(currentContextForPSFunctions, width);
}

void PSsetrgbcolor(float r, float g, float b)
{
    CGContextSetRGBStrokeColor(currentContextForPSFunctions, r, g, b, 1);
    CGContextSetRGBFillColor(currentContextForPSFunctions, r, g, b, 1);
}

void PSshow(const char* text)
{
    CGContextShowText(currentContextForPSFunctions, text, strlen(text));
}

void PSstroke()
{
    CGContextStrokePath(currentContextForPSFunctions);
}
