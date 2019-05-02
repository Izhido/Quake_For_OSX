#import <NXAlertPanel.h>

NSPanel* NXGetAlertPanel(const char* title, const char* message, const char* defaultButton, const char* alternateButton, const char* otherButton)
{
    NSString* titleAsString = nil;
    if (title != nil)
    {
        titleAsString = [NSString stringWithCString:title encoding:NSString.defaultCStringEncoding];
    }
    NSString* messageAsString = nil;
    if (message != nil)
    {
        messageAsString = [NSString stringWithCString:message encoding:NSString.defaultCStringEncoding];
    }
    NSString* defaultButtonAsString = nil;
    if (defaultButton != nil)
    {
        defaultButtonAsString = [NSString stringWithCString:defaultButton encoding:NSString.defaultCStringEncoding];
    }
    NSString* alternateButtonAsString = nil;
    if (alternateButton != nil)
    {
        alternateButtonAsString = [NSString stringWithCString:alternateButton encoding:NSString.defaultCStringEncoding];
    }
    NSString* otherButtonAsString = nil;
    if (otherButton != nil)
    {
        otherButtonAsString = [NSString stringWithCString:otherButton encoding:NSString.defaultCStringEncoding];
    }
    return NSGetAlertPanel(titleAsString, messageAsString, defaultButtonAsString, alternateButtonAsString, otherButtonAsString);
}

void NXFreeAlertPanel(NSPanel* panel)
{
    NSReleaseAlertPanel(panel);
}
