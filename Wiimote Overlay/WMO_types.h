//
//  WMO_types.h
//  Wiimote Overlay
//
//  Created by Karl Kirch on 6/9/15.
//  Copyright (c) 2015 Karl Kirch. All rights reserved.
//

#ifndef Wiimote_Overlay_WMO_types_h
#define Wiimote_Overlay_WMO_types_h

#import <stdbool.h>

#define MAX_NUM_POINTER_PRESS 10

typedef struct WMO_pointer_press {
    double press_time;
    bool active;
} WMO_pointer_press;

typedef struct WMO_status {
    double pointer_x, pointer_y;
    double rotation_angle;
    WMO_pointer_press pointer_presses[MAX_NUM_POINTER_PRESS];
} WMO_status;

#endif
