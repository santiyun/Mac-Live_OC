//
//  LiveWindowController.m
//  TTTLive
//
//  Created by yanzhen on 2018/9/30.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "LiveWindowController.h"
#import "TTTRtcManager.h"

@interface LiveWindowController ()<NSWindowDelegate>

@end

@implementation LiveWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (BOOL)windowShouldClose:(NSWindow *)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleCritical;
    alert.messageText = @"提示";
    alert.informativeText = @"你确定要结束连麦直播吗？";
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"确定"];
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == 1001) {
            [TTManager exitLiveRoom];
        }
    }];
    return NO;
}
@end
