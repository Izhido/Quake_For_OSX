#import "qedefs.h"

@implementation ZScrollView

/*
====================
initFrame: button:

Initizes a scroll view with a button at it's lower right corner
====================
*/

- /*/S&F*****initFrame*/createWithFrame:(const NXRect *)frameRect button1:b1
{
    //S&F*****[super  initFrame: frameRect];

	[self addSubview: b1];

	button1 = b1;

	[self setHorizScrollerRequired: YES];
	[self setVertScrollerRequired: YES];

	[self setBorderType: NX_BEZEL];
		
	return self;
}
/*/S&F*****>>>>>*/-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self != nil)
    {
        zscalemenu_i = [[PopUpList alloc] init];
        [zscalemenu_i setTarget: self];
        [zscalemenu_i setAction: @selector(scaleMenuTarget:)];
        
        [zscalemenu_i addItem: "12.5%"];
        [zscalemenu_i addItem: "25%"];
        [zscalemenu_i addItem: "50%"];
        [zscalemenu_i addItem: "75%"];
        [zscalemenu_i addItem: "100%"];
        [zscalemenu_i addItem: "200%"];
        [zscalemenu_i addItem: "300%"];
        [[zscalemenu_i itemList] selectCellAt: 4 : 0];
        
        zscalebutton_i = NXCreatePopUpListButton(zscalemenu_i);
        
        
        // initialize the scroll view
        zscrollview_i = self;
        [zscrollview_i setAutosizing: NX_WIDTHSIZABLE | NX_HEIGHTSIZABLE];
        
        NSRect frame = self.frame;
        [self createWithFrame:&frame button1:zscalebutton_i];
    }
    return self;
}

- scaleMenuTarget: sender
{
    return [zview_i scaleMenuTarget:sender];
}/*/S&F*****<<<<<*/

/*
================
tile

Adjust the size for the pop up scale menu
=================
*/

- tile
{
	NXRect	scrollerframe;
	
	[super tile];
	[hScroller getFrame: &scrollerframe];
	[/*/S&F*****/(Button*)/*/S&F*****/button1 setFrame: /*/S&F*****&*/scrollerframe];
	
	scrollerframe.size.width = 0;
	[hScroller setFrame: &scrollerframe];

	return self;
}



-(BOOL) acceptsFirstResponder
{
    return YES;
}

/*/S&F*****- superviewSizeChanged:(const NXSize *)oldSize
{
	[super superviewSizeChanged: oldSize];
	
	[[self docView] newSuperBounds];
	
	return self;
}/S&F*****/



@end

