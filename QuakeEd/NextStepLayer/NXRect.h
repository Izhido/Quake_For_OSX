#import <Foundation/Foundation.h>

typedef NSRect NXRect;

BOOL NXEqualRect(NXRect* first, NXRect* second);

BOOL NXIntersectsRect(NXRect* first, NXRect* second);

void NXUnionRect(NXRect* first, NXRect* second);

void NXSetRect(NXRect* rect, double x, double y, double width, double height);
