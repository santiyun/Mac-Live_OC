//
//  TTTUser.h
//  TTTLive
//
//  Created by yanzhen on 2018/10/11.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TTTRtcEngineKit/TTTRtcEngineKit.h>

@interface TTTUser : NSObject
@property int64_t uid;
@property BOOL mutedSelf; //是否静音
@property TTTRtcClientRole clientRole;
@property (readonly) BOOL isAnchor;

- (instancetype)initWith:(int64_t)uid;
@end

