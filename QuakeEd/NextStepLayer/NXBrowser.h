#import <AppKit/AppKit.h>

@protocol NXBrowserDataSource

-(int)browser:sender fillMatrix:matrix inColumn:(int)column;

@end

@interface NXBrowser : NSBrowser

@property (nonatomic, strong) id<NXBrowserDataSource> dataSource;

-(void)reuseColumns:(BOOL)reuse;

@end
