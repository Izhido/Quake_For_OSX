
#import "qedefs.h"

@implementation PopScrollView

/*
====================
initWithFrame: button:

Initizes a scroll view with a button at it's lower right corner
====================
*/

- initWithFrame:(NSRect)frameRect button1:(NSButton*)b1 button2:(NSButton*)b2
{
	self = [super initWithFrame: frameRect];	

	[self addSubview: b1];
	[self addSubview: b2];

	button1 = b1;
	button2 = b2;

    self.hasHorizontalScroller = YES;
    self.hasVerticalScroller = YES;

	[self setBorderType: NSBezelBorder];
		
	return self;
}


/*
================
tile

Adjust the size for the pop up scale menu
=================
*/

- tile
{
	NSRect	scrollerframe;
	NSRect	buttonframe, buttonframe2;
	NSRect	newframe;
	
	[super tile];
	buttonframe = button1.frame;
    buttonframe2 = button2.frame;
	scrollerframe = self.horizontalScroller.frame;

    newframe.origin.y = scrollerframe.origin.y + scrollerframe.size.height - 22;///**************************************************************scrollerframe.origin.y;
	newframe.origin.x = self.frame.size.width - 80 - self.verticalScroller.frame.size.width;///**************************************************************self.frame.size.width - buttonframe.size.width;
    newframe.size.width = 80;///**************************************************************buttonframe.size.width;
    newframe.size.height = 22;///**************************************************************scrollerframe.size.height;
	scrollerframe.size.width -= newframe.size.width;
	[button1 setFrame: newframe];
    ///**************************************************************newframe.size.width = buttonframe2.size.width;
	newframe.origin.x -= newframe.size.width;
	[button2 setFrame: newframe];
	scrollerframe.size.width -= newframe.size.width;
    scrollerframe.size.width -= self.verticalScroller.frame.size.width;

	[self.horizontalScroller setFrame: scrollerframe];

	return self;
}


- (void)resizeSubviewsWithOldSize:(NSSize)oldSize
{
    [super resizeSubviewsWithOldSize:oldSize];
	
	[[self documentView] newSuperBounds];
}


-(BOOL) acceptsFirstResponder
{
    return YES;
}



@end

