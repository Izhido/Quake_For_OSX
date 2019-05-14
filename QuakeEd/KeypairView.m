
#import "qedefs.h"

id	keypairview_i;

@implementation KeypairView

/*
==================
initFrame:
==================
*/
- initFrame:(const NXRect *)frameRect
{
	self = /*/S&F*****/[super initFrame:frameRect];
	keypairview_i = self;
	return self;
}

/*/S&F*****/-(BOOL)isFlipped { return YES; }
- calcViewSize
{
	NXCoord	w;
	NXCoord	h;
	NXRect	b;
	NXPoint	pt;
	int		count;
	id		ent;
	
	ent = [map_i currentEntity];
	count = [ent numPairs];

	//S&F*****[superview setFlipped: YES];
	
	b = self.superview.bounds;//S&F*****[superview getBounds:&b];
	w = b.size.width;
	h = LINEHEIGHT*count + SPACING;
	[self	sizeTo:w :h];
	pt.x = pt.y = 0;
	[self /*/S&F*****scrollPoint*/scrollPointAsNXPoint: &pt];
	return self;
}

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	epair_t	*pair;
	int		y;
	
	PSsetgray(NXGrayComponent(NX_COLORLTGRAY));
	PSrectfill(0,0,/*/S&F*****/self./*/S&F*****/bounds.size.width,/*/S&F*****/self./*/S&F*****/bounds.size.height);
		
	PSselectfont("Helvetica-Bold",FONTSIZE);
	PSrotate(0);
	PSsetgray(0);
	
	pair = [[map_i currentEntity] epairs];
	y = /*/S&F*****/self./*/S&F*****/bounds.size.height - LINEHEIGHT;
	for ( ; pair ; pair=pair->next)
	{
		PSmoveto(SPACING, y);
		PSshow(pair->key);
		PSmoveto(100, y);
		PSshow(pair->value);
		y -= LINEHEIGHT;
	}
	PSstroke();
	
	return self;
}

- mouseDown:(/*/S&F*****NXEvent*/NSEvent *)theEvent
{
	NXPoint	loc;
	int		i;
	epair_t	*p;

	loc.x = theEvent.locationInWindow.x; loc.y = theEvent.locationInWindow.y;//S&F*****loc = theEvent->location;
	[self /*/S&F*****convertPoint*/convertPointAsNXPoint:&loc	fromView:NULL];
	
	i = (/*/S&F*****/self./*/S&F*****/bounds.size.height - loc.y - 4) / LINEHEIGHT;

	p = [[map_i currentEntity] epairs];
	while (	i )
	{
		p=p->next;
		if (!p)
			return self;
		i--;
	}
	if (p)
		[things_i setSelectedKey: p];
	
	return self;
}

@end
