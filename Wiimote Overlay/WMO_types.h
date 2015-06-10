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
#define MAX_POINTER_PRESS_AGE 0.25

typedef enum WMO_buttons {
    WMO_buttons_A = 0,
    WMO_buttons_B = 1,
    WMO_buttons_MINUS = 2,
    WMO_buttons_PLUS = 3,
    WMO_buttons_HOME = 4,
    WMO_buttons_ONE = 5,
    WMO_buttons_TWO = 6
} WMO_buttons;

typedef enum WMO_button_state {
    WMO_button_state_UP = 0,
    WMO_button_state_PRESSED = 1
} WMO_button_state;

typedef struct WMO_pointer_press {
    double press_time;
    bool active;
    double press_x, press_y;
} WMO_pointer_press;

typedef struct WMO_status {
    double pointer_x, pointer_y;
    // access via WMO_buttons
    WMO_button_state button_state[8];
    double rotation_angle;
    WMO_pointer_press pointer_presses[MAX_NUM_POINTER_PRESS];
} WMO_status;

#endif
