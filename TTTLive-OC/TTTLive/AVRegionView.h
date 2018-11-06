//
//  AVRegionView.h
//  TTTLive
//
//  Created by yanzhen on 2018/9/30.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TTTUser;
@class TTTVideoPosition;
@interface AVRegionView : NSView
@property (strong) TTTUser *user;
@property (strong) TTTVideoPosition *videoPosition;

- (void)mutedSelf:(BOOL)mute;
- (void)configureRegion:(TTTUser *)user;
- (void)closeRegion;
- (void)reportAudioLevel:(NSUInteger)level;
- (void)setLocalAudioStats:(NSUInteger)stats;
- (void)setLocalVideoStats:(NSUInteger)stats;
- (void)setRemoterAudioStats:(NSUInteger)stats;
- (void)setRemoterVideoStats:(NSUInteger)stats;
@end

