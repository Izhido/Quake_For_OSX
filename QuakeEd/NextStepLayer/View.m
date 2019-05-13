#import <View.h>

@implementation View

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        NXRect frame = self.frame;
        self = [self initFrame:&frame];
    }
    return self;
}

-(instancetype)initFrame:(const NXRect*)frame
{
    return [super initWithFrame:*frame];
}

-(void)getBounds:(NXRect*)bounds
{
    bounds->origin = self.bounds.origin;
    bounds->size = self.bounds.size;
}

-(void)getFrame:(NXRect*)frame
{
    frame->origin = self.frame.origin;
    frame->size = self.frame.size;
}

-(void)getVisibleRect:(NXRect*)visibleRect
{
    visibleRect->origin = self.visibleRect.origin;
    visibleRect->size = self.visibleRect.size;
}

-(void)moveTo:(CGFloat)x :(CGFloat)y
{
    NSRect frame = self.frame;
    frame.origin.x = x;
    frame.origin.y = y;
    self.frame = frame;
}

-(void)sizeTo:(CGFloat)width :(CGFloat)height
{
    NSRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = height;
    self.frame = frame;
}

-(void)setDrawOrigin:(CGFloat)x :(CGFloat)y
{
    NSRect bounds = self.bounds;
    bounds.origin.x = x;
    bounds.origin.y = y;
    self.bounds = bounds;
}

-(void)setDrawSize:(CGFloat)width :(CGFloat)height
{
    NSRect bounds = self.bounds;
    bounds.size.width = width;
    bounds.size.height = height;
    self.bounds = bounds;
}

-(void)setDrawOriginInSuperview:(CGFloat)x :(CGFloat)y
{
    NSRect bounds = self.superview.bounds;
    bounds.origin.x = x;
    bounds.origin.y = y;
    self.superview.bounds = bounds;
}

-(void)setDrawSizeInSuperview:(CGFloat)width :(CGFloat)height
{
    NSRect bounds = self.superview.bounds;
    bounds.size.width = width;
    bounds.size.height = height;
    self.superview.bounds = bounds;
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

-(void)setAutosizing:(int)mask
{
    self.autoresizingMask = mask;
}

-(void)drawSelf:(const NXRect *)rects :(int)rectCount
{
}

-(void)drawRect:(NSRect)dirtyRect
{
    PSsetinstance(1);
    [self drawSelf:&dirtyRect :1];
    PSsetinstance(0);
}

-(void)convertPointAsNXPoint:(NXPoint*)point fromView:(NSView*)view
{
    NSPoint converted = [self convertPoint:NSMakePoint(point->x, point->y) fromView:view];
    point->x = converted.x;
    point->y = converted.y;
}

-(void)convertRectFromSuperview:(NXRect*)rect
{
    NSRect converted = [self convertRect:NSMakeRect(rect->origin.x, rect->origin.y, rect->size.width, rect->size.height) fromView:self.superview];
    rect->origin.x = converted.origin.x;
    rect->origin.y = converted.origin.y;
    rect->size.width = converted.size.width;
    rect->size.height = converted.size.height;
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
CGFloat currentXForPSFunctions = 0;
CGFloat currentYForPSFunctions = 0;
NSFont* currentFontForPSFunctions = nil;

void PSnewinstance()
{
}

void PSsetinstance(int instance)
{
    if (instance == 1)
    {
        currentContextForPSFunctions = NSGraphicsContext.currentContext.CGContext;
        currentXForPSFunctions = 0;
        currentYForPSFunctions = 0;
        currentFontForPSFunctions = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
    }
    else
    {
        currentContextForPSFunctions = nil;
    }
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
    NSString* nameAsString = [NSString stringWithCString:name encoding:NSString.defaultCStringEncoding];
    NSFont* newFont = nil;
    if (currentFontForPSFunctions == nil || ![currentFontForPSFunctions.fontName isEqualToString:nameAsString] || currentFontForPSFunctions.pointSize != size)
    {
        newFont = [NSFont fontWithName:nameAsString size:size];
    }
    if (newFont != nil)
    {
        currentFontForPSFunctions = newFont;
    }
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
    [[NSString stringWithCString:text encoding:NSString.defaultCStringEncoding] drawAtPoint:NSMakePoint(currentXForPSFunctions, currentYForPSFunctions) withAttributes:@{NSFontAttributeName:currentFontForPSFunctions, NSForegroundColorAttributeName: NSColor.blackColor}];
}

void PSstroke()
{
    CGContextStrokePath(currentContextForPSFunctions);
}
