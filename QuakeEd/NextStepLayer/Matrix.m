#import <Matrix.h>

@implementation Matrix
{
    id target;
    SEL action;
}

-(void)setTarget:(id)target
{
    self->target = target;
}

-(void)setAction:(SEL)action
{
    self->action = action;
}

-(int)selectedCol
{
    for (int i = 0; i < self.subviews.count; i++)
    {
        NSView* subview = self.subviews[i];
        if ([subview isKindOfClass:[NSButton class]])
        {
            NSButton* button = (NSButton*)subview;
            if (button.state == NSControlStateValueOn)
            {
                return i;
            }
        }
    }
    return -1;
}

-(id)cellAt:(int)row :(int)column
{
    return self.subviews[column * self.rowCount + row];
}

-(void)selectCellAt:(int)row :(int)column
{
    NSView* subview = self.subviews[column];
    if ([subview isKindOfClass:[NSButton class]])
    {
        NSButton* button = (NSButton*)subview;
        button.state = NSControlStateValueOn;
    }
}

- (IBAction)commonAction:(NSButton *)sender
{
    if ([target respondsToSelector:action])
    {
        [target performSelector:action withObject:self];
    }
}

@end
