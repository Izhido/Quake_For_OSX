#import "qedefs.h"

@implementation ZScrollView

/*
====================
initWithFrame: button:

Initizes a scroll view with a button at it's lower right corner
====================
*/

- initWithFrame:(NSRect)frameRect button1:b1
{
	self = [super initWithFrame: frameRect];	

	[self addSubview: b1];

	button1 = b1;

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
	
	[super tile];
    scrollerframe = self.horizontalScroller.frame;
    scrollerframe.origin.y = scrollerframe.origin.y + scrollerframe.size.height - 22;
    scrollerframe.size.height = 22;
    scrollerframe.size.width -= self.verticalScroller.frame.size.width;
	[button1 setFrame: scrollerframe];
	
	scrollerframe.size.width = 0;
	[self.horizontalScroller setFrame: scrollerframe];

	return self;
}



-(BOOL) acceptsFirstResponder
{
    return YES;
}

///**************************************************************- superviewSizeChanged:(const NXSize *)oldSize
/*{
	[super superviewSizeChanged: oldSize];
	
	[[self docView] newSuperBounds];
	
	return self;
}*/



@end

