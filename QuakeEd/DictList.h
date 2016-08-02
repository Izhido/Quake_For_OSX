
#import <AppKit/AppKit.h>

@interface DictList:NSObject
{
}

- initListFromFile:(FILE *)fp;
- writeListFile:(char *)filename;
- (id) findDictKeyword:(char *)key;

@end
