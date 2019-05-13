#import <NXBrowser.h>

@interface NXBrowser() <NSBrowserDelegate>

@end

@implementation NXBrowser

-(void)awakeFromNib
{
    self.delegate = self;
}

-(void)reuseColumns:(BOOL)reuse
{
    self.reusesColumns = reuse;
}

-(void)loadColumnZero
{
    if (self.lastColumn < 0)
    {
        [self addColumn];
    }
    [self reloadColumn:0];
}

-(void)browser:(NSBrowser *)sender createRowsForColumn:(NSInteger)column inMatrix:(NSMatrix *)matrix
{
    [self.dataSource browser:self fillMatrix:matrix inColumn:0];
}

@end
