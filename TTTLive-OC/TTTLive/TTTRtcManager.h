//
//  TTTRtcManager.h
//  TTTLive
//
//  Created by yanzhen on 2018/9/30.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <TTTRtcEngineKit/TTTRtcEngineKit.h>
#import "TTTUser.h"

#define TTManager [TTTRtcManager manager]

@interface TTTRtcManager : NSObject
@property (strong) TTTRtcEngineKit *rtcEngine;
@property (strong) TTTUser *me;

@property (strong) NSWindowController *loginWindow;
@property (nullable, strong) NSWindowController *liveWindow;
@property (assign) int64_t roomID;

+ (instancetype)manager;
- (void)exitLiveRoom;
@end

