//
//  WMO_DisplayView.m
//  Wiimote Overlay
//
//  Created by Karl Kirch on 6/9/15.
//  Copyright (c) 2015 Karl Kirch. All rights reserved.
//

#import "WMO_DisplayView.h"

#define CURSOR_WIDTH 10.0
#define HALF_CURSOR_WIDTH CURSOR_WIDTH / 2.0
#define MAX_PRESS_RADIUS 60.0

@interface WMO_DisplayView()

@property WMO_status * status;
@property NSLock * statusLock;
@property NSImage * cursorHandImage;

@end

@implementation WMO_DisplayView

- (id)initWithFrame:(NSRect)frameRect andStatus:(WMO_status *)status andStatusLock:(NSLock *)statusLock {
    self = [super initWithFrame:frameRect];
    
    if (self) {
        _status = status;
        _statusLock = statusLock;
        _cursorHandImage = [NSImage imageNamed:@"cursor-hand"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            while (true) {
                [self setNeedsDisplay:YES];
                NSTimeInterval sleep = 0.0167777;
                [NSThread sleepForTimeInterval: sleep];
                if ([[self window] isOnActiveSpace]) {
                    [NSCursor hide];
                } else {
                    [NSCursor unhide];
                }
            }
        });
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [_statusLock lock];
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    // draw presses
    [[NSColor blackColor] setStroke];
    for (int i = 0; i < MAX_NUM_POINTER_PRESS; ++i) {
        WMO_pointer_press pointerPress = _status->pointer_presses[i];
        if (pointerPress.active) {
            double age = now - pointerPress.press_time;
            if (age > MAX_POINTER_PRESS_AGE) {
                // deactivate press
                _status->pointer_presses[i].active = false;
                continue;
            }
            double ageDt = ((MAX_POINTER_PRESS_AGE - age) / MAX_POINTER_PRESS_AGE);
            double radius = MAX_PRESS_RADIUS - MAX_PRESS_RADIUS * ageDt;
            double halfRadius = radius / 2;
            NSColor *fillColor = [NSColor colorWithDeviceRed:48.0 / 255.0 green:213.0 / 255.0 blue:200.0 / 255.0 alpha:0.5];
            [fillColor setFill];
            NSRect rect = NSMakeRect(pointerPress.press_x - halfRadius, pointerPress.press_y - halfRadius, radius, radius);
            NSBezierPath* circlePath = [NSBezierPath bezierPath];
            [circlePath appendBezierPathWithOvalInRect: rect];
            [circlePath fill];
            [circlePath stroke];
        }
    }
    
    // draw pointer
    NSPoint cursorPoint = NSMakePoint(_status->pointer_x - 50, _status->pointer_y - 150);
    [_cursorHandImage drawAtPoint:cursorPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    
    // draw debug point
    if (_status->button_state[WMO_buttons_A] == WMO_button_state_PRESSED) {
        [[NSColor greenColor] setFill];
        [[NSColor greenColor] setStroke];
    } else {
        [[NSColor redColor] setFill];
        [[NSColor redColor] setStroke];
    }
    NSRect cursorRect = NSMakeRect(_status->pointer_x - HALF_CURSOR_WIDTH,
                                   _status->pointer_y - HALF_CURSOR_WIDTH,
                                   CURSOR_WIDTH, CURSOR_WIDTH);
    NSRectFill(cursorRect);
    
    [_statusLock unlock];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

@end
