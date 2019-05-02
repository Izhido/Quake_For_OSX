#import <Storage.h>

@implementation Storage
{
    NSMutableData* data;
    size_t elementSize;
    NSString* description;
}

-(instancetype)initCount:(int)count elementSize:(size_t)elementSize description:(NSString*)description
{
    self = [super init];
    if (self != nil)
    {
        numElements = count;
        data = [NSMutableData dataWithLength:count * elementSize];
        dataPtr = data.bytes;
        self->elementSize = elementSize;
        self->description = description;
    }
    return self;
}

-(NSUInteger)count
{
    return numElements;
}

-(void*)elementAt:(int)index
{
    return (void*)((unsigned char*)data.bytes) + index * elementSize;
}

-(void)addElement:(void*)element
{
    [data appendBytes:element length:elementSize];
    numElements++;
}

-(void)removeElementAt:(int)index
{
    NSMutableData* newData = [NSMutableData dataWithLength:(numElements - 1) * elementSize];
    memcpy(newData.bytes, data.bytes, index * elementSize);
    memcpy(newData.bytes + index * elementSize, data.bytes + (index + 1) * elementSize, (numElements - index - 1) * elementSize);
    data = newData;
}

-(void)replaceElementAt:(int)index with:(void*)element
{
    if (index < 0 || index * elementSize >= data.length)
    {
        return;
    }
    unsigned char* toReplace = ((unsigned char*)data.bytes) + index * elementSize;
    memcpy(toReplace, element, elementSize);
}

-(id)copyFromZone:(NXZone*)zone
{
    return [[Storage alloc] initCount:numElements elementSize:elementSize description:description];
}

@end
