#include <AppKit/AppKit.h>

NSPanel* NXGetAlertPanel(const char* title, const char* message, const char* defaultButton , const char* alternateButton, const char* otherButton);

void NXFreeAlertPanel(NSPanel* panel);
