#import <Cocoa/Cocoa.h>
#import <NXRect.h>

@interface View : NSView

-(instancetype)initFrame:(const NXRect*)frame;

-(void)getBounds:(NXRect*)bounds;

-(void)getVisibleRect:(NXRect*)visibleRect;

-(void)sizeTo:(int)width :(int)height;

-(void)scrollPointAsNXPoint:(NXPoint*)point;

-(void)scrollRectToVisibleAsNXRect:(const NXRect *)rect;

-(void)setAutoresizeSubviews:(BOOL)autoresizeSubviews;

@end

void NXDrawBitmap(NXRect* rect, int width, int height, int bps, int spp, int bpp, int bpr, BOOL isPlanar, BOOL hasAlpha, NSColorSpaceName colorSpaneName, const char* planes);

void NXEraseRect(NXRect* rect);

int NXGrayComponent(int gray);

void NXRectClip(NXRect* rect);

void NXRectFill(NXRect* rect);

int NXRunAlertPanel(const char* title, const char* msgFormat, const char* defaultButton, const char* alternateButton, const char* otherButton);

void PSusecontext(CGContextRef context);

void PSarc(float x, float y, float radius, float startAngle, float endAngle);

void PSfill();

void PSlineto(float x, float y);

void PSmoveto(float x, float y);

void PSrectfill(float x, float y, float width, float height);

void PSrectstroke(float x, float y, float width, float height);

void PSrlineto(float x, float y);

void PSrotate(float angle);

void PSselectfont(const char* font, float size);

void PSsetgray(float gray);

void PSsetlinewidth(float width);

void PSsetrgbcolor(float r, float g, float b);

void PSshow(const char* text);

void PSstroke();
