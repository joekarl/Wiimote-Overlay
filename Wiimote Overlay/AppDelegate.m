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

@property NSWindow * window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Init window
    NSRect frame = [[NSScreen mainScreen] frame];
    _window = [[NSWindow alloc] initWithContentRect:frame
                                          styleMask:NSBorderlessWindowMask
                                            backing:NSBackingStoreBuffered
                                              defer:NO];
    WMO_DisplayView *displayView = [[WMO_DisplayView alloc] initWithFrame:frame];
    
    [_window setContentView:displayView];
    [_window setAcceptsMouseMovedEvents:NO];
    [_window setIgnoresMouseEvents:YES];
    [_window setOpaque:NO];
    [_window setBackgroundColor:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:0.2]];
    [_window orderFrontRegardless];
    [_window setStyleMask:NSUtilityWindowMask | NSNonactivatingPanelMask | NSBorderlessWindowMask];
    [_window setLevel:NSMainMenuWindowLevel + 1];
    [_window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorFullScreenAuxiliary];
    
    // Init wiimote sync lock
    NSLock *wiimoteLock = [[NSLock alloc] init];
    
    // Init wiimotes
    wiimote **wiimotes = WMO_WiimoteManager_init(NUM_WIIMOTES);
    
    [self runWiimoteManager:wiimotes andLock:wiimoteLock];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
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
            end = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval sleep = 0.0167777 - (end - start);
            if (sleep > 0) {
                [NSThread sleepForTimeInterval: sleep];
            }
        }
    });
}

@end
