
#import "qedefs.h"

// Add .h-files here for new inspectors
#import	"Things.h"
#import	"TexturePalette.h"
#import	"Preferences.h"

InspectorControl		*inspcontrol_i;

@implementation InspectorControl

- awakeFromNib
{
	inspcontrol_i = self;
    
    inspectorView_i = quakeed_i->inspector_i;
    popUpButton_i = quakeed_i->inspectorsel_i;
		
	currentInspectorType = -1;

	contentList = [[NSMutableArray alloc] init];
	windowList = [[NSMutableArray alloc] init];
	itemList = [[NSMutableArray alloc] init];

	// ADD NEW INSPECTORS HERE...

    win_project_i = [quakeed_i.storyboard instantiateControllerWithIdentifier:@"win_project"];
	[windowList addObject:win_project_i];
	[contentList addObject:[win_project_i view]];
    itemProject_i = quakeed_i->inspectorsel_project_i;
    [itemProject_i setKeyEquivalent:@"1"];
	[itemList addObject:itemProject_i];

    win_textures_i = [quakeed_i.storyboard instantiateControllerWithIdentifier:@"win_textures"];
	[windowList addObject:win_textures_i];
	[contentList addObject:[win_textures_i view]];
    itemTextures_i = quakeed_i->inspectorsel_textures_i;
    [itemTextures_i setKeyEquivalent:@"2"];
	[itemList addObject:itemTextures_i];

    win_things_i = [quakeed_i.storyboard instantiateControllerWithIdentifier:@"win_things"];
	[windowList addObject:win_things_i];
	[contentList addObject:[win_things_i view]];
    itemThings_i = quakeed_i->inspectorsel_things_i;
    [itemThings_i setKeyEquivalent:@"3"];
	[itemList addObject:itemThings_i];
	
    win_prefs_i = [quakeed_i.storyboard instantiateControllerWithIdentifier:@"win_prefs"];
	[windowList addObject:win_prefs_i];
	[contentList addObject:[win_prefs_i view]];
    itemPrefs_i = quakeed_i->inspectorsel_prefs_i;
    [itemPrefs_i setKeyEquivalent:@"4"];
	[itemList addObject:itemPrefs_i];

    win_settings_i = [quakeed_i.storyboard instantiateControllerWithIdentifier:@"win_settings"];
	[windowList addObject:win_settings_i];
	[contentList addObject:[win_settings_i view]];
    itemSettings_i = quakeed_i->inspectorsel_settings_i;
    [itemSettings_i setKeyEquivalent:@"5"];
	[itemList addObject:itemSettings_i];

    win_output_i = [quakeed_i.storyboard instantiateControllerWithIdentifier:@"win_output"];
	[windowList addObject:win_output_i];
	[contentList addObject:[win_output_i view]];
    itemOutput_i = quakeed_i->inspectorsel_output_i;
    [itemOutput_i setKeyEquivalent:@"6"];
	[itemList addObject:itemOutput_i];

    win_help_i = [quakeed_i.storyboard instantiateControllerWithIdentifier:@"win_help"];
	[windowList addObject:win_help_i];
	[contentList addObject:[win_help_i view]];
    itemHelp_i = quakeed_i->inspectorsel_help_i;
    [itemHelp_i setKeyEquivalent:@"7"];
	[itemList addObject:itemHelp_i];

	// Setup inspector window with project subview first

	[inspectorView_i setAutoresizesSubviews:YES];

    inspectorSubviewController_i = [windowList objectAtIndex:i_project];
    [quakeed_i addChildViewController:inspectorSubviewController_i];
	inspectorSubview_i = [contentList objectAtIndex:i_project];
	[inspectorView_i addSubview:inspectorSubview_i];


	//currentInspectorType = -1;
	//[self changeInspectorTo:i_project];

	return self;
}


//
//	Sent by the PopUpList in the Inspector
//	Each cell in the PopUpList must have the correct tag
//
- (void)changeInspector:(NSPopUpButton *)sender
{
	[self changeInspectorTo:(insp_e)sender.selectedTag];
}

//
//	Change to specific Inspector
//
- changeInspectorTo:(insp_e)which
{
	id		newView;
	NSRect	r;
	id		cell;
	NSRect	f;
	
	if (which == currentInspectorType)
		return self;

    [inspectorSubviewController_i removeFromParentViewController];
    
	currentInspectorType = which;
	newView = [contentList objectAtIndex:which];
	
	cell = [itemList objectAtIndex:which];	// set PopUpButton title
	///**************************************************************[popUpButton_i setTitle:[cell title]];
	
    inspectorSubviewController_i = [windowList objectAtIndex:which];
    [quakeed_i addChildViewController:inspectorSubviewController_i];
    
	[inspectorView_i replaceSubview:inspectorSubview_i with:newView];
	///**************************************************************[inspectorView_i getFrame:&r];
	inspectorSubview_i = newView;
	///**************************************************************[inspectorSubview_i setAutosizing:NX_WIDTHSIZABLE | NX_HEIGHTSIZABLE];
	///**************************************************************[inspectorSubview_i sizeTo:r.size.width - 4 :r.size.height - 4];

    ///**************************************************************[inspectorSubview_i lockFocus];
	///**************************************************************[inspectorSubview_i getBounds:&f];
	///**************************************************************PSsetgray(NX_LTGRAY);
	///**************************************************************NSRectFill(f);
	///**************************************************************[inspectorSubview_i unlockFocus];
	[inspectorView_i display];
	
	return self;
}

- (insp_e)getCurrentInspector
{
	return currentInspectorType;
}


@end
