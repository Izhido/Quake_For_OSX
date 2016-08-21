
#import "qedefs.h"

QuakeEd	*quakeed_i;
id	entclasses_i;

id	g_cmd_out_i;

BOOL	autodirty;
BOOL	filter_light, filter_path, filter_entities;
BOOL	filter_clip_brushes, filter_water_brushes, filter_world;

BOOL	running;

int bsppid;

char workdirectory[4096];

#if 0
// example command strings

char	*fullviscmd = "rsh satan \"/LocalApps/qbsp $1 $2 ; /LocalApps/light $2 ; /LocalApps/vis $2\"";
char	*fastviscmd = "rsh satan \"/LocalApps/qbsp $1 $2 ; /LocalApps/light $2 ; /LocalApps/vis -fast $2\"";
char	*noviscmd = "rsh satan \"/LocalApps/qbsp $1 $2 ; /LocalApps/light $2\"";
char	*relightcmd = "rsh satan \"/LocalApps/light $2\"";
char	*leakcmd = "rsh satan \"/LocalApps/qbsp -mark -notjunc $1 $2\"";
#endif

void NopSound (void)
{
	NSBeep ();
}

///**************************************************************UserPath	*upath;


void My_Malloc_Error (int code)
{
// recursive toast	Error ("Malloc error: %i\n", code);
	write (1, "malloc error!\n", strlen("malloc error!\n")+1);
}

/*
===============
AutoSave

Every five minutes, save a modified map
===============
*/
void AutoSave()
{
// automatic backup
	if (autodirty)
	{
		autodirty = NO;
        
        char path[4096];
        strcpy (path, [quakeed_i workDirectory]);
        strcat (path, FN_AUTOSAVE);
		
        [map_i writeMapFile: path useRegion: NO];
	}
	[map_i writeStats];
}


void DisplayCmdOutput (void)
{
	char	*buffer;

    char path[4096];
    strcpy (path, [quakeed_i workDirectory]);
    strcat (path, FN_CMDOUT);
    
	LoadFile (path, (void **)&buffer);
	unlink (path);
	[project_i addToOutput:buffer];
	free (buffer);

	if ([preferences_i getShowBSP])
		[inspcontrol_i changeInspectorTo:i_output];

	[preferences_i playBspSound];		
	
	///**************************************************************NXPing ();
}

/*
===============
CheckCmdDone

See if the BSP is done
===============
*/
NSTimer	*cmdte;
void CheckCmdDone()
{
    union wait statusp;
    struct rusage rusage;
	
	if (!wait4(bsppid, &statusp, WNOHANG, &rusage))
		return;
	DisplayCmdOutput ();
	bsppid = 0;
    [cmdte invalidate];
    cmdte = nil;
}

//============================================================================

@implementation QuakeEd

- (void)invokeAutoSave:(NSTimer*)timer
{
    AutoSave();
}

/*
===============
init
===============
*/
- (void)viewDidLoad
{
    [super viewDidLoad];

    workdirectory[0] = 0;

    char path[4096];
    strcpy(path, [self workDirectory]);
    strcat(path, "/tmp");

    [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithCString:path encoding:[NSString defaultCStringEncoding]] withIntermediateDirectories:YES attributes:nil error:nil];

    strcpy(path, [self workDirectory]);
    strcat(path, "/qcache");
	
    [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithCString:path encoding:[NSString defaultCStringEncoding]] withIntermediateDirectories:YES attributes:nil error:nil];

    ///**************************************************************[self addToEventMask:
	///**************************************************************	NX_RMOUSEDRAGGEDMASK|NX_LMOUSEDRAGGEDMASK];
	
    ///**************************************************************malloc_error(My_Malloc_Error);
	
	quakeed_i = self;
	dirty = autodirty = NO;

    [[Clipper alloc] init];
    [[Map alloc] init];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(invokeAutoSave:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
	///**************************************************************upath = newUserPath ();
}

- (void)viewWillAppear
{
    [self appDidInit:self];
}

- setDefaultFilename
{	
    char path[4096];
    strcpy (path, [quakeed_i workDirectory]);
    strcat (path, FN_TEMPSAVE);

    strcpy (filename, path);
	[self setTitleAsFilename:filename];
	
	return self;
}


- (BOOL)dirty
{
	return dirty;
}

/*
===============================================================================

				DISPLAY UPDATING (handles both camera and XYView)

===============================================================================
*/

BOOL	updateinflight;

BOOL	clearinstance;

BOOL	updatexy;
BOOL	updatez;
BOOL	updatecamera;

void postappdefined (void)
{
	NXEvent ev;

	if (updateinflight)
		return;
			
// post an event at the end of the que
	ev.type = NX_APPDEFINED;
	///**************************************************************if (DPSPostEvent(&ev, 0) == -1)
	///**************************************************************	printf ("WARNING: DPSPostEvent: full\n");
//printf ("posted\n");
	updateinflight = YES;
}


int	c_updateall;
- updateAll			// when a model has been changed
{
	updatecamera = updatexy = updatez = YES;
	c_updateall++;
	postappdefined ();
	return self;
}

- updateAll:sender
{
	[self updateAll];
	return self;
}

- updateCamera		// when the camera has moved
{
	updatecamera = YES;
	clearinstance = YES;
	
	postappdefined ();
	return self;
}

- updateXY
{
	updatexy = YES;
	postappdefined ();
	return self;
}

- updateZ
{
	updatez = YES;
	postappdefined ();
	return self;
}


- newinstance
{
	clearinstance = YES;
	return self;
}

- redrawInstance
{
	clearinstance = YES;
	[self flushWindow];
	return self;
}

/*
===============
flushWindow

instance draw the brush after each flush
===============
*/
-flushWindow
{
	///**************************************************************[super flushWindow];
	/*
	if (!running || in_error)
		return self;		// don't lock focus before nib is finished loading
		
	if (_flushDisabled)
		return self;
		
	[cameraview_i lockFocus];	
	if (clearinstance)
	{
		PSnewinstance ();
		clearinstance = NO;
	}

	PSsetinstance (1);
	linestart (0,0,0);
	[map_i makeSelectedPerform: @selector(CameraDrawSelf)];
	[clipper_i cameraDrawSelf];
	lineflush ();
	PSsetinstance (0);
	[cameraview_i unlockFocus];	

	[xyview_i lockFocus];
	PSsetinstance (1);
	linestart (0,0,0);
	[map_i makeSelectedPerform: @selector(XYDrawSelf)];
	lineflush ();
	[cameraview_i XYDrawSelf];
	[zview_i XYDrawSelf];
	[clipper_i XYDrawSelf];
	PSsetinstance (0);
	[xyview_i unlockFocus];

	[zview_i lockFocus];
	PSsetinstance (1);
	[map_i makeSelectedPerform: @selector(ZDrawSelf)];
	[cameraview_i ZDrawSelf];
	[clipper_i ZDrawSelf];
	PSsetinstance (0);
	[zview_i unlockFocus];*/

	return self;
}


/*
==============================================================================

App delegate methods

==============================================================================
*/

- applicationDefined:(NXEvent *)theEvent
{
///**************************************************************	NXEvent		ev, *evp;
/*
	updateinflight = NO;

//printf ("serviced\n");
	
// update screen	
	evp = [NXApp peekNextEvent:-1 into:&ev];
	if (evp)
	{
		postappdefined();
		return self;
	}

		
	[self disableFlushWindow];	

	if ([map_i count] != [entitycount_i intValue])
		[entitycount_i setIntValue: [map_i count]];
	if ([[map_i currentEntity] count] != [brushcount_i intValue])
		[brushcount_i setIntValue: [[map_i currentEntity] count]];
		
	if (updatecamera)
		[cameraview_i display];
	if (updatexy)
		[xyview_i display];
	if (updatez)
		[zview_i display];

	updatecamera = updatexy = updatez = NO;

	[self reenableFlushWindow];
	[self flushWindow];
	
//	NXPing ();*/
	
	return self;
}

- appDidInit:sender
{
	///**************************************************************NXScreen	const *screens;
	///**************************************************************int			screencount;
	
	running = YES;
	g_cmd_out_i = cmd_out_i;	// for qprintf

	[preferences_i	readDefaults];
	[project_i		initializeProject];

	[xyview_i setModeRadio: xy_drawmode_i];	// because xy view is inside
											// scrollview and can't be
											// connected directly in IB
	
	///**************************************************************[self setFrameAutosaveName:"EditorWinFrame"];
	[self clear: self];

// go to my second monitor
	///**************************************************************[NXApp getScreens:&screens count:&screencount];
	///**************************************************************if (screencount == 2)
	///**************************************************************	[self moveTopLeftTo:0 : screens[1].screenBounds.size.height
	///**************************************************************	screen:screens+1];
	
	///**************************************************************[self makeKeyAndOrderFront: self];

//[self doOpen: "/raid/quake/id1_/maps/amlev1.map"];	// DEBUG
	[map_i newMap];
		
	qprintf ("ready.");

//malloc_debug(-1);		// DEBUG
	
	return self;
}

- appWillTerminate:sender
{
// FIXME: save dialog if dirty
	return self;
}


//===========================================================================

- (IBAction)textCommand:(NSTextField *)sender
{
	char	const *t;

    t = [[sender stringValue] cStringUsingEncoding:[NSString defaultCStringEncoding]];
	
	if (!strcmp (t, "texname"))
	{
		texturedef_t	*td;
		id				b;
		
		b = [map_i selectedBrush];
		if (!b)
		{
			qprintf ("nothing selected");
			return;
		}
		td = [b texturedef];
		qprintf (td->texture);
		return;
	}
	else
		qprintf ("Unknown command\n");
}


- openProject:sender
{
	///**************************************************************[project_i	openProject];
	return self;
}


- clear: sender
{	
	[map_i newMap];

	[self updateAll];
	[regionbutton_i setIntValue: 0];
	[self setDefaultFilename];

	return self;
}


- centerCamera: sender
{
	NSRect	sbounds;
	
	sbounds = [[xyview_i superview] bounds];
	
	sbounds.origin.x += sbounds.size.width/2;
	sbounds.origin.y += sbounds.size.height/2;
	
	[cameraview_i setXYOrigin: &sbounds.origin];
	[self updateAll];
	
	return self;
}

- centerZChecker: sender
{
	NSRect	sbounds;
	
	sbounds = [[xyview_i superview] bounds];
	
	sbounds.origin.x += sbounds.size.width/2;
	sbounds.origin.y += sbounds.size.height/2;
	
	[zview_i setPoint: &sbounds.origin];
	[self updateAll];
	
	return self;
}

- (IBAction)changeXYLookUp:(NSButton *)sender
{
	if ([sender intValue])
	{
		xy_viewnormal[2] = 1;
	}
	else
	{
		xy_viewnormal[2] = -1;
	}
	[self updateAll];
}

/*
==============================================================================

REGION MODIFICATION

==============================================================================
*/


/*
==================
applyRegion:
==================
*/
- (IBAction)applyRegion:(NSButton *)sender
{
	filter_clip_brushes = [filter_clip_i intValue];
	filter_water_brushes = [filter_water_i intValue];
	filter_light = [filter_light_i intValue];
	filter_path = [filter_path_i intValue];
	filter_entities = [filter_entities_i intValue];
	filter_world = [filter_world_i intValue];

	if (![regionbutton_i intValue])
	{
		region_min[0] = region_min[1] = region_min[2] = -9999;
		region_max[0] = region_max[1] = region_max[2] = 9999;
	}

	[map_i makeGlobalPerform: @selector(newRegion)];
	
	[self updateAll];
}

- (IBAction)setBrushRegion:(NSButton *)sender
{
	id		b;

// get the bounds of the current selection
	
	if ([map_i numSelected] != 1)
	{
		qprintf ("must have a single brush selected");
		return;
	} 

	b = [map_i selectedBrush];
	[b getMins: region_min maxs: region_max];
	///**************************************************************[b remove];

// turn region on
	[regionbutton_i setIntValue: 1];
	[self applyRegion: regionbutton_i];
}

- (IBAction)setXYRegion:(NSButton *)sender
{
	NSRect	bounds;
	
// get xy size
	bounds = [[xyview_i superview] bounds];

	region_min[0] = bounds.origin.x;
	region_min[1] = bounds.origin.y;
	region_min[2] = -99999;
	region_max[0] = bounds.origin.x + bounds.size.width;
	region_max[1] = bounds.origin.y + bounds.size.height;
	region_max[2] = 99999;
	
// turn region on
	[regionbutton_i setIntValue: 1];
	[self applyRegion: regionbutton_i];
}

- (IBAction)inspectorsel_change:(NSPopUpButton *)sender
{
    [inspcontrol_i changeInspector:sender];
}

//
// UI querie for other objects
//
- (BOOL)showCoordinates
{
	return [show_coordinates_i intValue];
}

- (BOOL)showNames
{
	return [show_names_i intValue];
}


/*
==============================================================================

BSP PROCESSING

==============================================================================
*/

void ExpandCommand (char *in, char *out, char *src, char *dest)
{
	while (*in)
	{
		if (in[0] == '$')
		{
			if (in[1] == '1')
			{
				strcpy (out, src);
				out += strlen(src);
			}
			else if (in[1] == '2')
			{
				strcpy (out, dest);
				out += strlen(dest);
			}
			in += 2;			
			continue;
		}
		*out++ = *in++;
	}
	*out = 0;
}

- (void)invokeCheckCmdDone:(NSTimer*)timer
{
    CheckCmdDone();
}

/*
=============
saveBSP
=============
*/
- saveBSP:(char *)cmdline dialog:(BOOL)wt
{
	char	expandedcmd[1024];
	char	mappath[1024];
	char	bsppath[1024];
	int		oldLightFilter;
	int		oldPathFilter;
	char	*destdir;
	
	if (bsppid)
	{
		NSBeep();
		return self;
	}

//
// turn off the filters so all entities get saved
//
	oldLightFilter = [filter_light_i intValue];
	oldPathFilter = [filter_path_i intValue];
	[filter_light_i setIntValue:0];
	[filter_path_i setIntValue:0];
	[self applyRegion: regionbutton_i];
	
	if ([regionbutton_i intValue])
	{
		strcpy (mappath, filename);
		StripExtension (mappath);
		strcat (mappath, ".reg");
		[map_i writeMapFile: mappath useRegion: YES];
		wt = YES;		// allways pop the dialog on region ops
	}
	else
		strcpy (mappath, filename);
		
// save the entire thing, just in case there is a problem
	[self saveDocument: self];

	[filter_light_i setIntValue:oldLightFilter];
	[filter_path_i setIntValue:oldPathFilter];
	[self applyRegion: regionbutton_i];

//
// write the command to the bsp host
//	
	destdir = [project_i getFinalMapDirectory];

	strcpy (bsppath, destdir);
	strcat (bsppath, "/");
	ExtractFileBase (mappath, bsppath + strlen(bsppath));
	strcat (bsppath, ".bsp");
	
	ExpandCommand (cmdline, expandedcmd, mappath, bsppath);

	strcat (expandedcmd, " > ");
    strcpy (expandedcmd, [quakeed_i workDirectory]);
    strcat (expandedcmd, FN_CMDOUT);
	strcat (expandedcmd, "\n");
	printf ("system: %s", expandedcmd);

	[project_i addToOutput: "\n\n========= BUSY =========\n\n"];
	[project_i addToOutput: expandedcmd];

	if ([preferences_i getShowBSP])
		[inspcontrol_i changeInspectorTo:i_output];
	
	if (wt)
	{
		///**************************************************************id		panel;
		/*
		panel = NXGetAlertPanel("BSP In Progress",expandedcmd,NULL,NULL,NULL);
		[panel makeKeyAndOrderFront:NULL];
		system(expandedcmd);
		NXFreeAlertPanel(panel);
		[self makeKeyAndOrderFront:NULL];*/
		DisplayCmdOutput ();
	}
	else
	{
        cmdte = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(invokeCheckCmdDone:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:cmdte forMode:NSRunLoopCommonModes];
		if (! (bsppid = fork ()) )
		{
			system (expandedcmd);
			exit (0);
		}
	}
	
	return self;
}


- BSP_Full: sender
{
	[self saveBSP:[project_i getFullVisCmd] dialog: NO];
	return self;
}

- BSP_FastVis: sender
{
	[self saveBSP:[project_i getFastVisCmd] dialog: NO];
	return self;
}

- BSP_NoVis: sender
{
	[self saveBSP:[project_i getNoVisCmd] dialog: NO];
	return self;
}

- BSP_relight: sender
{
	[self saveBSP:[project_i getRelightCmd] dialog: NO];
	return self;
}

- BSP_entities: sender
{
	[self saveBSP:[project_i getEntitiesCmd] dialog: NO];
	return self;
}

- BSP_stop: sender
{
	if (!bsppid)
	{
		NSBeep();
		return self;
	}
	
	kill (bsppid, 9);
	CheckCmdDone ();
	[project_i addToOutput: "\n\n========= STOPPED =========\n\n"];
	
	return self;
}



/*
==============
doOpen:

Called by open or the project panel
==============
*/
- doOpen: (const char *)fname;
{	
	strcpy (filename, fname);
	
	[map_i readMapFile:filename];
	
	[regionbutton_i setIntValue: 0];
	[self setTitleAsFilename:fname];
	[self updateAll];

	qprintf ("%s loaded\n", fname);
	
	return self;
}


/*
==============
open
==============
*/
- (void)openDocument: (id)sender
{
	NSOpenPanel			*openpanel;

	openpanel = [NSOpenPanel openPanel];
    openpanel.allowedFileTypes = @[ @"map" ];
    openpanel.directoryURL = [NSURL fileURLWithPath:[NSString stringWithCString:[project_i getMapDirectory] encoding:[NSString defaultCStringEncoding]]];
    [openpanel beginWithCompletionHandler:^(NSInteger result) {
        
        if (result == NSFileHandlingPanelOKButton)
        {
            [self doOpen:openpanel.URLs[0].fileSystemRepresentation];
        }
        
    }];
}


/*
==============
save:
==============
*/
- (void)saveDocument: (id)sender
{
	char		backup[1024];

// force a name change if using tempname
    
    char path[4096];
    strcpy(path, [quakeed_i workDirectory]);
    strcat(path, FN_TEMPSAVE);

    if (!strcmp (filename, path) )
		return [self saveDocumentAs: self];
		
	dirty = autodirty = NO;

	strcpy (backup, filename);
	StripExtension (backup);
	strcat (backup, ".bak");
	rename (filename, backup);		// copy old to .bak

	[map_i writeMapFile: filename useRegion: NO];
}


/*
==============
saveAs
==============
*/
- (void)saveDocumentAs: (id)sender
{
	NSSavePanel		*panel_i;
	char	dir[1024];
	
	panel_i = [NSSavePanel savePanel];
	ExtractFileBase (filename, dir);
    panel_i.allowedFileTypes = @[ @"map" ];
    panel_i.directoryURL = [NSURL fileURLWithPath:[NSString stringWithCString:[project_i getMapDirectory] encoding:[NSString defaultCStringEncoding]]];
    [panel_i setNameFieldStringValue:[NSString stringWithCString:dir encoding:[NSString defaultCStringEncoding]]];
    [panel_i beginWithCompletionHandler:^(NSInteger result) {
        
        if (result == NSFileHandlingPanelOKButton)
        {
            strcpy (filename, [[panel_i URL] fileSystemRepresentation]);
            
            [self setTitleAsFilename:filename];
            
            [self saveDocument: self];
        }

    }];
}


/*
===============================================================================

						OTHER METHODS

===============================================================================
*/


//
//	AJR - added this for Project info
//
- (char *)currentFilename
{
	return filename;
}

- deselect: sender
{
	if ([clipper_i hide])	// first click hides clipper only
		return [self updateAll];

	[map_i setCurrentEntity: [map_i objectAtIndex: 0]];	// make world selected
	[map_i makeSelectedPerform: @selector(deselect)];
	[self updateAll];
	
	return self;
}


/*
===============
keyDown
===============
*/

#define	KEY_RIGHTARROW		0xae
#define	KEY_LEFTARROW		0xac
#define	KEY_UPARROW			0xad
#define	KEY_DOWNARROW		0xaf

- (void)keyDown:(NSEvent *)theEvent
{
    int		ch;
	
// function keys
	switch (theEvent.keyCode)
	{
	case 0x78:	// F2
		[cameraview_i setDrawMode: dr_wire];
		qprintf ("wire draw mode");
		return;
	case 0x63:	// F3
		[cameraview_i setDrawMode: dr_flat];
		qprintf ("flat draw mode");
		return;
	case 0x76:	// F4
		[cameraview_i setDrawMode: dr_texture];
		qprintf ("texture draw mode");
		return;

	case 0x60:	// F5
		[xyview_i setDrawMode: dr_wire];
		qprintf ("wire draw mode");
		return;
	case 0x61:	// F6
		qprintf ("texture draw mode");
		return;
		
	case 0x64:	// F8
		[cameraview_i homeView: self];
		return;
		
	case 0x6F:	// F12
		[map_i subtractSelection: self];
		return;

	case 0x74:	// page up
		[cameraview_i upFloor: self];
		return;
		
	case 0x79:	// page down
		[cameraview_i downFloor: self];
		return;
		
	case 0x77:	// end
		[self deselect: self];
		return;
	}

// portable things
    ch = tolower([theEvent.charactersIgnoringModifiers characterAtIndex:0]);
		
	switch (ch)
	{
	case KEY_RIGHTARROW:
	case KEY_LEFTARROW:
	case KEY_UPARROW:
	case KEY_DOWNARROW:
	case 'a':
	case 'z':
	case 'd':
	case 'c':
	case '.':
	case ',':
		[cameraview_i _keyDown: theEvent];
		break;

	case 27:	// escape
		autodirty = dirty = YES;
		[self deselect: self];
		return;
		
	case 127:	// delete
		autodirty = dirty = YES;
		[map_i makeSelectedPerform: @selector(remove)];
		[clipper_i hide];
		[self updateAll];
		break;

	case '/':
		[clipper_i flipNormal];
		[self updateAll];
		break;
		
	case 13:	// enter
		[clipper_i carve];
		[self updateAll];
		qprintf ("carved brush");
		break;
		
	case ' ':
		[map_i cloneSelection: self];
		break;
		

//
// move selection keys
//		
	case '2':
		VectorCopy (vec3_origin, sb_translate);
		sb_translate[1] = -[xyview_i gridsize];
		[map_i makeSelectedPerform: @selector(translate)];
		[self updateAll];
		break;
	case '8':
		VectorCopy (vec3_origin, sb_translate);
		sb_translate[1] = [xyview_i gridsize];
		[map_i makeSelectedPerform: @selector(translate)];
		[self updateAll];
		break;

	case '4':
		VectorCopy (vec3_origin, sb_translate);
		sb_translate[0] = -[xyview_i gridsize];
		[map_i makeSelectedPerform: @selector(translate)];
		[self updateAll];
		break;
	case '6':
		VectorCopy (vec3_origin, sb_translate);
		sb_translate[0] = [xyview_i gridsize];
		[map_i makeSelectedPerform: @selector(translate)];
		[self updateAll];
		break;

	case '-':
		VectorCopy (vec3_origin, sb_translate);
		sb_translate[2] = -[xyview_i gridsize];
		[map_i makeSelectedPerform: @selector(translate)];
		[self updateAll];
		break;
	case '+':
		VectorCopy (vec3_origin, sb_translate);
		sb_translate[2] = [xyview_i gridsize];
		[map_i makeSelectedPerform: @selector(translate)];
		[self updateAll];
		break;

	default:
		qprintf ("undefined keypress");
		NopSound ();
		break;
	}
}

- (BOOL)makeFirstResponder:(id)responder
{
    [[[self view] window] makeFirstResponder:[[responder view] window]];
    return YES;
}

- (void)enableFlushWindow
{
    [[[self view] window] enableFlushWindow];
}

- (void)disableFlushWindow
{
    [[[self view] window] disableFlushWindow];
}

- (void)setTitleAsFilename:(const char*)filenameTitle
{
    [[[self view] window] setTitleWithRepresentedFilename:[NSString stringWithCString:filenameTitle encoding:[NSString defaultCStringEncoding]]];
}

- (char*)workDirectory
{
    if (strlen(workdirectory) == 0)
    {
        NSString *path;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"QuakeEd"];
        strcpy(workdirectory, [path cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    }
    return workdirectory;
}

@end
