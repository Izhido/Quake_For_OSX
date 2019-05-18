#import <Foundation/Foundation.h>

@interface SavePanel : NSObject

-(void)setRequiredFileType:(const char*)type;

-(int)runModalForDirectoryAsString:(const char*)path file:(const char*)file;

-(char*)filenameAsString;

@end
