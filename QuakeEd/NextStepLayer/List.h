#import <Foundation/Foundation.h>

@interface List : NSObject
{
    int numElements;
}

-(NSUInteger)count;

-(void)empty;

-(id)objectAt:(int)index;

-(void)addObject:(id)object;

-(void)removeObjectAt:(int)index;

-(void)insertObject:(id)object at:(int)index;

-(int)indexOf:(id)object;

-(id)removeObject:(id)object;

-(void)appendList:(List*)list;

-(id)free;

@end
