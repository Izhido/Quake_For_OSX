
#import "qedefs.h"

@implementation PopScrollView

/*
====================
initFrame: button:

Initizes a scroll view with a button at it's lower right corner
====================
*/

- initFrame:(const NXRect *)frameRect button1:b1 button2:b2
{
	self = /*/S&F*****/[super  initFrame: frameRect];

	[self addSubview: b1];
	[self addSubview: b2];

	button1 = b1;
	button2 = b2;

	[self setHorizScrollerRequired: YES];
	[self setVertScrollerRequired: YES];

	[self setBorderType: NX_BEZEL];
		
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
	NXRect	scrollerframe;
	NXRect	buttonframe, buttonframe2;
	NXRect	newframe;
	
	[super tile];
	[button1 getFrame: &buttonframe];
	[button2 getFrame: &buttonframe2];
	[hScroller getFrame: &scrollerframe];

	newframe.origin.y = scrollerframe.origin.y;
	newframe.origin.x = /*/S&F*****/self./*/S&F*****/frame.size.width - buttonframe.size.width;
	newframe.size.width = buttonframe.size.width;
	newframe.size.height = scrollerframe.size.height;
	scrollerframe.size.width -= newframe.size.width;
	[/*/S&F*****/(Button*)/*/S&F*****/button1 setFrame: /*/S&F*****&*/newframe];
	newframe.size.width = buttonframe2.size.width;
	newframe.origin.x -= newframe.size.width;
	[/*/S&F*****/(Button*)/*/S&F*****/button2 setFrame: /*/S&F*****&*/newframe];
	scrollerframe.size.width -= newframe.size.width;

	[hScroller setFrame: &scrollerframe];

	return self;
}


/*/S&F*****- superviewSizeChanged:(const NXSize *)oldSize
{
	[super superviewSizeChanged: oldSize];
	
	[[self docView] newSuperBounds];
	
	return self;
}/S&F*****/


-(BOOL) acceptsFirstResponder
{
    return YES;
}



@end

