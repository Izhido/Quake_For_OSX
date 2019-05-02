#import <NXZone.h>

NXZone* NXCreateZone(NSUInteger startSize, NSUInteger granularity, BOOL canFree)
{
    return NSCreateZone(startSize, granularity, canFree);
}

void* NXZoneMalloc(NSZone *zone, NSUInteger size)
{
    return NSZoneMalloc(zone, size);
}

void* NXZoneRealloc(NXZone *zone, void *ptr, NSUInteger size)
{
    return NSZoneRealloc(zone, ptr, size);
}
