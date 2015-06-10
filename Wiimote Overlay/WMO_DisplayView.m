//
//  WMO_DisplayView.m
//  Wiimote Overlay
//
//  Created by Karl Kirch on 6/9/15.
//  Copyright (c) 2015 Karl Kirch. All rights reserved.
//

#import "WMO_DisplayView.h"

@interface WMO_DisplayView()

- (NSEvent *)handleEvent:(NSEvent *)theEvent;

@property id globalEventMonitor, localEventMonitor;

@end

@implementation WMO_DisplayView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    NSEventMask eventMasks = NSLeftMouseDownMask |
                             NSLeftMouseUpMask |
                             NSMouseMovedMask |
                             NSLeftMouseDraggedMask |
                             NSRightMouseDownMask |
                             NSRightMouseUpMask;
    
    if (self) {
        // Create monitors for both local and global mouse events
        _globalEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:eventMasks handler:^(NSEvent *incomingEvent) {
            [self handleEvent:incomingEvent];
        }];
        _localEventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:eventMasks handler:^(NSEvent *incomingEvent) {
            return [self handleEvent:incomingEvent];
        }];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSEvent *)handleEvent:(NSEvent *)theEvent {
    NSPoint eventLocation = [theEvent locationInWindow];
    //NSLog(@"Mouse event x:%f y:%f", eventLocation.x, eventLocation.y);
    
    BOOL isMoving = [theEvent type] == NSMouseMoved;
    
    return theEvent;
}

- (BOOL)acceptsFirstResponder {
    return NO;
}

@end
