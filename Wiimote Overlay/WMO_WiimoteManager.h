//
//  WMO_WiimoteManager.h
//  Wiimote Overlay
//
//  Created by Karl Kirch on 6/9/15.
//  Copyright (c) 2015 Karl Kirch. All rights reserved.
//

#ifndef __Wiimote_Overlay__WMO_WiimoteManager__
#define __Wiimote_Overlay__WMO_WiimoteManager__

#include "wiiuse.h"

wiimote** WMO_WiimoteManager_init(int num_wiimotes);
void WMO_WiimoteManager_update_wiimotes(wiimote** wiimotes);

#endif /* defined(__Wiimote_Overlay__WMO_WiimoteManager__) */
