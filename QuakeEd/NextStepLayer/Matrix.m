#import <Matrix.h>

@implementation Matrix
{
    NSMutableDictionary<NSNumber*, NSMutableDictionary<NSNumber*, id>*>* cells;
}

-(void)addViewAtRow:(int)row column:(int)column view:(NSView*)view
{
    if (cells == nil)
    {
        cells = [NSMutableDictionary<NSNumber*, NSMutableDictionary<NSNumber*, id>*> new];
    }
    NSNumber* rowKey = @(row);
    NSMutableDictionary<NSNumber*, id>* rowDictionary = [cells objectForKey:rowKey];
    if (rowDictionary == nil)
    {
        rowDictionary = [NSMutableDictionary<NSNumber*, id> new];
        [cells setObject:rowDictionary forKey:rowKey];
    }
    NSNumber* columnKey = @(column);
    [rowDictionary setObject:view forKey:columnKey];
}

-(id)cellAt:(int)row :(int)column
{
    NSMutableDictionary<NSNumber*, id>* rowDictionary = [cells objectForKey:@(row)];
    return [rowDictionary objectForKey:@(column)];
}

-(void)selectCellAt:(int)row :(int)column
{
    NSMutableDictionary<NSNumber*, id>* rowDictionary = [cells objectForKey:@(row)];
    id cell = [rowDictionary objectForKey:@(column)];
    [((NSButton*)cell) setState:NSOnState];
}

@end
