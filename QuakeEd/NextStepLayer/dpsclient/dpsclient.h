#import <IOKit/hidsystem/IOLLEvent.h>
#import <NXZone.h>
#import <NXHandler.h>

typedef enum _DPSUserPathOp {
    dps_setbbox,
    dps_moveto,
    dps_rmoveto,
    dps_lineto,
    dps_rlineto,
    dps_curveto,
    dps_rcurveto,
    dps_arc,
    dps_arcn,
    dps_arct,
    dps_closepath,
    dps_ucache
} DPSUserPathOp;

#define dps_err_ps 1000

#define dps_float 48

#define dps_ustroke 0
