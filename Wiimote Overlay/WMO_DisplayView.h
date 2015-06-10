//
//  WMO_DisplayView.h
//  Wiimote Overlay
//
//  Created by Karl Kirch on 6/9/15.
//  Copyright (c) 2015 Karl Kirch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WMO_types.h"

@interface WMO_DisplayView : NSView

- (id)initWithFrame:(NSRect)frameRect andStatus:(WMO_status *)status andStatusLock:(NSLock *)statusLock;

@end
