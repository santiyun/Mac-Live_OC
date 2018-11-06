//
//  AppDelegate.m
//  TTTLive
//
//  Created by yanzhen on 2018/9/26.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "AppDelegate.h"
#import "TTTRtcManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!TTManager.liveWindow) {
        [TTManager.loginWindow showWindow:self];
    }
    return YES;
}
@end
