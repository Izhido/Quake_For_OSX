#import <Foundation/Foundation.h>
#import <NXZone.h>

@interface Storage : NSObject
{
    int numElements;
    void* dataPtr;
}

-(instancetype)initCount:(int)count elementSize:(size_t)elementSize description:(NSString*)description;

-(NSUInteger)count;

-(void*)elementAt:(int)index;

-(void)addElement:(void*)element;

-(void)removeElementAt:(int)index;

-(void)replaceElementAt:(int)index with:(void*)element;

-(id)copyFromZone:(NXZone*)zone;

@end
