#import <NXHandler.h>
#import <Foundation/Foundation.h>

NXHandler NXLocalHandler;

void NXReportError(NXHandler* error)
{
    NSLog(@"NXReportError: %i", error->code);
}
