
#import "qedefs.h"

KeypairView	*keypairview_i;

@implementation KeypairView

/*
==================
initWithFrame:
==================
*/
- initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame: frameRect];
	keypairview_i = self;
	return self;
}


- calcViewSize
{
	CGFloat	w;
	CGFloat	h;
	NSRect	b;
	NSPoint	pt;
	int		count;
	id		ent;
	
	ent = [map_i currentEntity];
	count = [ent numPairs];

	///**************************************************************[superview setFlipped: YES];
	
    b = self.superview.bounds;
	w = b.size.width;
	h = LINEHEIGHT*count + SPACING;
	///**************************************************************[self	sizeTo:w :h];
	pt.x = pt.y = 0;
	[self scrollPoint: pt];
	return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	epair_t	*pair;
	int		y;
	
	///**************************************************************PSsetgray(NXGrayComponent(NX_COLORLTGRAY));
	/*PSrectfill(0,0,self.bounds.size.width,self.bounds.size.height);
		
	PSselectfont("Helvetica-Bold",FONTSIZE);
	PSrotate(0);
	PSsetgray(0);
	
	pair = [[map_i currentEntity] epairs];
	y = self.bounds.size.height - LINEHEIGHT;
	for ( ; pair ; pair=pair->next)
	{
		PSmoveto(SPACING, y);
		PSshow(pair->key);
		PSmoveto(100, y);
		PSshow(pair->value);
		y -= LINEHEIGHT;
	}
	PSstroke();*/
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint	loc;
	int		i;
	epair_t	*p;

	loc = theEvent.locationInWindow;
	[self convertPoint:loc	fromView:NULL];
	
	i = (self.bounds.size.height - loc.y - 4) / LINEHEIGHT;

	p = [[map_i currentEntity] epairs];
	while (	i )
	{
		p=p->next;
		if (!p)
			return;
		i--;
	}
	if (p)
		[things_i setSelectedKey: p];
}

@end
