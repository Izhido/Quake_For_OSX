@class QuakeEd;

extern	QuakeEd	*quakeed_i;

extern	BOOL	filter_light, filter_path, filter_entities;
extern	BOOL	filter_clip_brushes, filter_water_brushes, filter_world;

extern	CGMutablePathRef	upath;

extern	id	g_cmd_out_i;

double I_FloatTime (void);

void NopSound (void);

void qprintf (char *fmt, ...);		// prints text to cmd_out_i

@interface QuakeEd : NSViewController
{
	BOOL	dirty;
	char	filename[1024];		// full path with .map extension

// UI objects
    __weak IBOutlet NSTextField *brushcount_i;
    __weak IBOutlet NSTextField *entitycount_i;
    __weak IBOutlet NSButton *regionbutton_i;

    __weak IBOutlet NSButton *show_coordinates_i;
    __weak IBOutlet NSButton *show_names_i;

    __weak IBOutlet NSButton *filter_light_i;
    __weak IBOutlet NSButton *filter_path_i;
    __weak IBOutlet NSButton *filter_entities_i;
    __weak IBOutlet NSButton *filter_clip_i;
    __weak IBOutlet NSButton *filter_water_i;
    __weak IBOutlet NSButton *filter_world_i;
	
    __weak IBOutlet NSTextField *cmd_in_i;		// text fields
    __weak IBOutlet NSTextField *cmd_out_i;
	
	id		xy_drawmode_i;	// passed over to xyview after init
    
    @public __weak IBOutlet NSView *inspector_i;

    @public __weak IBOutlet NSPopUpButton *inspectorsel_i;
    
    @public __weak IBOutlet NSMenuItem *inspectorsel_project_i;
    @public __weak IBOutlet NSMenuItem *inspectorsel_textures_i;
    @public __weak IBOutlet NSMenuItem *inspectorsel_things_i;
    @public __weak IBOutlet NSMenuItem *inspectorsel_prefs_i;
    @public __weak IBOutlet NSMenuItem *inspectorsel_settings_i;
    @public __weak IBOutlet NSMenuItem *inspectorsel_output_i;
    @public __weak IBOutlet NSMenuItem *inspectorsel_help_i;
}

- setDefaultFilename;
- (char *)currentFilename;

- updateAll;		// when a model has been changed
- updateCamera;		// when the camera has moved
- updateXY;
- updateZ;

- updateAll:sender;

- newinstance;		// force next flushwindow to clear all instance drawing
- redrawInstance;	// erase and redraw all instance now

- appDidInit:sender;
- appWillTerminate:sender;

- (IBAction)openProject:sender;

- (IBAction)textCommand:(NSTextField *)sender;

- (IBAction)applyRegion:(NSButton *)sender;

- (BOOL)dirty;

- (IBAction)clear: sender;
- centerCamera: sender;
- centerZChecker: sender;

- (IBAction)changeXYLookUp:(NSButton *)sender;

- (IBAction)setBrushRegion:(NSButton *)sender;
- (IBAction)setXYRegion:(NSButton *)sender;

- (IBAction)inspectorsel_change:(NSPopUpButton *)sender;

- open: sender;
- save: sender;
- (IBAction)saveAs: sender;

- doOpen: (const char *)fname;

- saveBSP:(char *)cmdline dialog:(BOOL)wt;

- (IBAction)BSP_Full: sender;
- (IBAction)BSP_FastVis: sender;
- (IBAction)BSP_NoVis: sender;
- (IBAction)BSP_relight: sender;
- (IBAction)BSP_stop: sender;
- (IBAction)BSP_entities: sender;

//
// UI querie for other objects
//
- (BOOL)showCoordinates;
- (BOOL)showNames;

- (BOOL)makeFirstResponder:(id)responder;

- (void)enableFlushWindow;
- (void)disableFlushWindow;
- (void)setTitleAsFilename:(const char*)filename;

- (char*)workDirectory;

@end

