
#import <AppKit/AppKit.h>

@class Things;

extern	Things	*things_i;

#define	ENTITYNAMEKEY	"spawn"

@interface Things:NSViewController
{
    __weak IBOutlet NSBrowser *entity_browser_i;	// browser
    __unsafe_unretained IBOutlet NSTextView *entity_comment_i; // scrolling text window
	
	id	prog_path_i;
	
	int	lastSelected;	// last row selected in browser

	id	keyInput_i;
	id	valueInput_i;
	NSArray<NSButton*>	*flags_i;
}

- initEntities;

- newCurrentEntity;
- setSelectedKey:(epair_t *)ep;

- clearInputs;
- (char *)spawnName;

// UI targets
- reloadEntityClasses: sender;
- selectEntity: sender;
- doubleClickEntity: sender;

// Action methods
///**************************************************************- addPair:sender;
///**************************************************************- delPair:sender;
- setAngle:sender;
///**************************************************************- setFlags:sender;


@end
