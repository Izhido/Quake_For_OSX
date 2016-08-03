#import <AppKit/AppKit.h>

@interface PopScrollView : NSScrollView
{
	NSButton	*button1, *button2;
}

- initWithFrame:(NSRect)frameRect button1: (NSButton*)b1 button2: (NSButton*)b2;
- tile;

@end