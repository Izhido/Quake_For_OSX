typedef struct _NXHandler
{
    int code;
} NXHandler;

extern NXHandler NXLocalHandler;

void NXReportError(NXHandler* error);
