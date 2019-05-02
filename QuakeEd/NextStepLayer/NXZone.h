#import <Foundation/Foundation.h>

typedef NSZone NXZone;

NXZone* NXCreateZone(NSUInteger startSize, NSUInteger granularity, BOOL canFree);
void* NXZoneMalloc(NXZone *zone, NSUInteger size);
void* NXZoneRealloc(NXZone *zone, void *ptr, NSUInteger size);
