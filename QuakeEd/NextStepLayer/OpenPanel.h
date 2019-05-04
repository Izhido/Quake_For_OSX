#import <Foundation/Foundation.h>

@interface OpenPanel : NSObject

-(void)allowMultipleFiles:(BOOL)allow;

-(void)chooseDirectories:(BOOL)choose;

-(int)runModalForDirectoryAsString:(const char*)path file:(const char*)file types:(char**)types;

-(int)runModalForTypesAsStringList:(char**)types;

-(char*)filenameAsString;

-(char**)filenamesAsStringList;

-(char*)directoryAsString;

@end
