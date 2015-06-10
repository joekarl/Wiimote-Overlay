//
//  AppDelegate.m
//  Wiimote Overlay
//
//  Created by Karl Kirch on 6/9/15.
//  Copyright (c) 2015 Karl Kirch. All rights reserved.
//

#import "AppDelegate.h"
#import "WMO_WiimoteManager.h"
#import "WMO_DisplayView.h"
#import "WMO_types.h"

#define NUM_WIIMOTES 1

@interface AppDelegate ()

- (void)runWiimoteManager:(wiimote**)wiimotes andLock:(NSLock *)wiimoteLock;
- (NSEvent *)handleEvent:(NSEvent *)theEvent;

@property id globalEventMonitor, localEventMonitor;
@property NSWindow * window;
@property NSLock * wmoStatusLock;
@property WMO_status * wmoStatus;
@property WMO_DisplayView *displayView;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    _wmoStatusLock = [[NSLock alloc] init];
    _wmoStatus = calloc(1, sizeof(WMO_status));
    
    // Init window
    NSRect frame = [[NSScreen mainScreen] frame];
    _window = [[NSWindow alloc] initWithContentRect:frame
                                          styleMask:NSBorderlessWindowMask
                                            backing:NSBackingStoreBuffered
                                              defer:NO];
    _displayView = [[WMO_DisplayView alloc] initWithFrame:frame
                                                andStatus:_wmoStatus
                                            andStatusLock:_wmoStatusLock];
    
    [_window setContentView:_displayView];
    [_window setAcceptsMouseMovedEvents:NO];
    [_window setIgnoresMouseEvents:YES];
    [_window setOpaque:NO];
    [_window setBackgroundColor:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:0.2]];
    [_window orderFrontRegardless];
    [_window setStyleMask: NSBorderlessWindowMask];
    [_window setLevel:NSScreenSaverWindowLevel];
    [_window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorFullScreenAuxiliary];
    
    void CGSSetConnectionProperty(int, int, CFStringRef, CFBooleanRef);
    int _CGSDefaultConnection();
    CFStringRef propertyString;
    
    // Hack to make background cursor setting work
    propertyString = CFStringCreateWithCString(NULL, "SetsCursorInBackground", kCFStringEncodingUTF8);
    CGSSetConnectionProperty(_CGSDefaultConnection(), _CGSDefaultConnection(), propertyString, kCFBooleanTrue);
    CFRelease(propertyString);
    CGDisplayHideCursor(kCGDirectMainDisplay);
    
    NSEventMask eventMasks = NSLeftMouseDownMask |
                             NSLeftMouseUpMask |
                             NSMouseMovedMask |
                             NSLeftMouseDraggedMask |
                             NSRightMouseDownMask |
                             NSRightMouseUpMask;
    
    // Create monitors for both local and global mouse events
    _globalEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:eventMasks handler:^(NSEvent *incomingEvent) {
        [self handleEvent:incomingEvent];
    }];
    _localEventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:eventMasks handler:^(NSEvent *incomingEvent) {
        return [self handleEvent:incomingEvent];
    }];
    
    // Init wiimote sync lock
    NSLock *wiimoteLock = [[NSLock alloc] init];
    
    // Init wiimotes
    wiimote **wiimotes = WMO_WiimoteManager_init(NUM_WIIMOTES);
    
    [self runWiimoteManager:wiimotes andLock:wiimoteLock];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (NSEvent *)handleEvent:(NSEvent *)theEvent {
    //NSLog(@"Mouse event x:%f y:%f", eventLocation.x, eventLocation.y);
    
    NSEventType eventType = [theEvent type];
    BOOL isMoving = eventType == NSMouseMoved || eventType == NSLeftMouseDragged;
    BOOL isMouseClick = eventType == NSLeftMouseDown || eventType == NSRightMouseDown;
    BOOL isMouseUp = eventType == NSLeftMouseUp || eventType == NSRightMouseUp;
    
    if (isMoving) {
        NSPoint eventLocation = [theEvent locationInWindow];
        [_wmoStatusLock lock];
        _wmoStatus->pointer_x = eventLocation.x;
        _wmoStatus->pointer_y = eventLocation.y;
        [_wmoStatusLock unlock];
    }
    
    if (isMouseClick) {
        NSPoint eventLocation = [theEvent locationInWindow];
        [_wmoStatusLock lock];
        _wmoStatus->button_state[WMO_buttons_A] = WMO_button_state_PRESSED;
        for (int i = 0; i < MAX_NUM_POINTER_PRESS; ++i) {
            if (!_wmoStatus->pointer_presses[i].active) {
                _wmoStatus->pointer_presses[i].active = true;
                _wmoStatus->pointer_presses[i].press_time = [[NSDate date] timeIntervalSince1970];
                _wmoStatus->pointer_presses[i].press_x = eventLocation.x;
                _wmoStatus->pointer_presses[i].press_y = eventLocation.y;
                break;
            }
        }
        [_wmoStatusLock unlock];
    }
    
    if (isMouseUp) {
        [_wmoStatusLock lock];
        _wmoStatus->button_state[WMO_buttons_A] = WMO_button_state_UP;
        [_wmoStatusLock unlock];
    }

    return theEvent;
}

- (void)runWiimoteManager:(wiimote **)wiimotes andLock:(NSLock *)wiimoteLock {
    // Start updating wiimotes in the background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSTimeInterval start, end;
        while (true) {
            start = [[NSDate date] timeIntervalSince1970];
            // Synchronize access to wiimotes
            [wiimoteLock lock];
            WMO_WiimoteManager_update_wiimotes(wiimotes);
            [wiimoteLock unlock];
            
            NSPoint mouseLoc = [NSEvent mouseLocation];
            [_wmoStatusLock lock];
            _wmoStatus->pointer_x = mouseLoc.x;
            _wmoStatus->pointer_y = mouseLoc.y;
            [_wmoStatusLock unlock];
            
            end = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval sleep = 0.0167777 - (end - start);
            if (sleep > 0) {
                [NSThread sleepForTimeInterval: sleep];
            }
        }
    });
}

@end
