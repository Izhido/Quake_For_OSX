#import <List.h>

@implementation List
{
    NSMutableArray* list;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        list = [NSMutableArray new];
        numElements = 0;
    }
    return self;
}

-(NSUInteger)count
{
    return list.count;
}

-(void)empty
{
    [list removeAllObjects];
    numElements = 0;
}

-(id)objectAt:(int)index
{
    return [list objectAtIndex:index];
}

-(void)addObject:(id)object
{
    [list addObject:object];
    numElements++;
}

-(void)removeObjectAt:(int)index
{
    [list removeObjectAtIndex:index];
    numElements--;
}

-(void)insertObject:(id)object at:(int)index
{
    [list insertObject:object atIndex:index];
}

-(int)indexOf:(id)object
{
    return [list indexOfObject:object];
}

-(id)removeObject:(id)object
{
    int position = [list indexOfObject:object];
    if (position == NSNotFound)
    {
        return nil;
    }
    [list removeObjectAtIndex:position];
    numElements--;
    return object;
}

-(void)appendList:(List*)list
{
    [self->list addObjectsFromArray:list->list];
    numElements += list.count;
}

-(id)free
{
    return self;
}

@end
