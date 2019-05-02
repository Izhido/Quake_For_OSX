#include <NXRect.h>

BOOL NXEqualRect(NXRect* first, NXRect* second)
{
    return NSEqualRects(*first, *second);
}

BOOL NXIntersectsRect(NXRect* first, NXRect* second)
{
    return NSIntersectsRect(*first, *second);
}

void NXSetRect(NXRect* rect, CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    *rect = NSMakeRect(x, y, width, height);
}
