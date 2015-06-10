//
//  WMO_WiimoteManager.cpp
//  Wiimote Overlay
//
//  Created by Karl Kirch on 6/9/15.
//  Copyright (c) 2015 Karl Kirch. All rights reserved.
//

#include "WMO_WiimoteManager.h"
#include <stdbool.h>
#include <stdio.h>

wiimote** WMO_WiimoteManager_init(int num_wiimotes)
{
    wiimote** wiimotes = wiiuse_init(num_wiimotes);
    return wiimotes;
}


void WMO_WiimoteManager_update_wiimotes(wiimote** wiimotes)
{
    // Update wiimotes
    
}