//
//  LiveViewController.m
//  TTTLive
//
//  Created by yanzhen on 2018/9/30.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "LiveViewController.h"
#import "TTTRtcManager.h"
#import "AVRegionView.h"
#import "TTTVideoPosition.h"
#import "NSView+Toast.h"

@interface LiveViewController ()<TTTRtcEngineDelegate>
@property (weak) IBOutlet NSImageView *anchorVideoView;
@property (weak) IBOutlet NSButton *voiceBtn;
@property (weak) IBOutlet NSTextField *roomIDLabel;
@property (weak) IBOutlet NSTextField *anchorIDLabel;
@property (weak) IBOutlet NSTextField *audioStatsLabel;
@property (weak) IBOutlet NSTextField *videoStatsLabel;
@property (weak) IBOutlet NSView *avRegionsView;

@property (strong) NSMutableArray<AVRegionView *> *avRegions;
@property (strong) NSMutableArray<TTTUser *> *users;
@property (strong) TTTRtcVideoCompositingLayout *videoLayout;
@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = NSColor.whiteColor.CGColor;
    
    _users = [NSMutableArray array];
    _avRegions = [NSMutableArray arrayWithCapacity:6];
    for (NSView *subView in _avRegionsView.subviews) {
        if ([subView isKindOfClass:[AVRegionView class]]) {
            [_avRegions addObject:(AVRegionView *)subView];
        }
    }
    
    _roomIDLabel.stringValue = [NSString stringWithFormat:@"房号: %lld", TTManager.roomID];
    [_users addObject:TTManager.me];
    TTManager.rtcEngine.delegate = self;
    
    if (TTManager.me.isAnchor) {
        _anchorIDLabel.stringValue = [NSString stringWithFormat:@"主播ID: %lld", TTManager.me.uid];
        [TTManager.rtcEngine startPreview];
        TTTRtcVideoCanvas *videoCanvas = [[TTTRtcVideoCanvas alloc] init];
        videoCanvas.renderMode = TTTRtc_Render_Adaptive;
        videoCanvas.uid = TTManager.me.uid;
        videoCanvas.view = _anchorVideoView;
        [TTManager.rtcEngine setupLocalVideo:videoCanvas];
        
        _videoLayout = [[TTTRtcVideoCompositingLayout alloc] init];
        _videoLayout.canvasWidth = 640;
        _videoLayout.canvasHeight = 360;
        _videoLayout.backgroundColor = @"#e8e6e8";
    } else if (TTManager.me.clientRole == TTTRtc_ClientRole_Broadcaster) {
        [TTManager.rtcEngine startPreview];
    }
}

- (IBAction)enableLocalAudio:(NSButton *)sender {
    if (TTManager.me.isAnchor) {
        if (sender.tag == 0) {
            sender.tag = 1;
            TTManager.me.mutedSelf = YES;
        } else {
            sender.tag = 0;
            TTManager.me.mutedSelf = NO;
        }
        [TTManager.rtcEngine muteLocalAudioStream:TTManager.me.mutedSelf];
        [_voiceBtn setImage:[self getVoiceImage:0]];
    }
}


#pragma mark - TTTRtcEngineDelegate
- (void)rtcEngine:(TTTRtcEngineKit *)engine didJoinedOfUid:(int64_t)uid clientRole:(TTTRtcClientRole)clientRole isVideoEnabled:(BOOL)isVideoEnabled elapsed:(NSInteger)elapsed {
    TTTUser *user = [[TTTUser alloc] initWith:uid];
    user.clientRole = clientRole;
    [_users addObject:user];
    if (clientRole == TTTRtc_ClientRole_Anchor) {
        _anchorIDLabel.stringValue = [NSString stringWithFormat:@"主播ID: %lld", uid];
        TTTRtcVideoCanvas *videoCanvas = [[TTTRtcVideoCanvas alloc] init];
        videoCanvas.renderMode = TTTRtc_Render_Adaptive;
        videoCanvas.uid = uid;
        videoCanvas.view = _anchorVideoView;
        [engine setupRemoteVideo:videoCanvas];
    } else if (clientRole == TTTRtc_ClientRole_Broadcaster) {
        if (TTManager.me.isAnchor) {
            [[self getAVRegion:0] configureRegion:user];
            [self refreshVideoCompositingLayout];
        }
    } else {
        if (TTManager.me.isAnchor) {
            [self refreshVideoCompositingLayout];
        }
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine onSetSEI:(NSString *)SEI {
    if (TTManager.me.isAnchor) { return; }
    NSData *seiData = [SEI dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:seiData options:NSJSONReadingMutableLeaves error:nil];
    NSArray<NSDictionary *> *posArray = json[@"pos"];
    for (NSDictionary *obj in posArray) {
        int64_t uid = [obj[@"id"] longLongValue];
        TTTUser *user = [self getUser:uid];
        if (user.clientRole == TTTRtc_ClientRole_Broadcaster) {
            if (![self getAVRegion:uid]) {
                TTTVideoPosition *videoPosition = [[TTTVideoPosition alloc] init];
                videoPosition.x = [obj[@"x"] doubleValue];
                videoPosition.y = [obj[@"y"] doubleValue];
                videoPosition.w = [obj[@"w"] doubleValue];
                videoPosition.h = [obj[@"h"] doubleValue];
                [[self positionAVRegion:videoPosition] configureRegion:user];
            }
        }
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine didOfflineOfUid:(int64_t)uid reason:(TTTRtcUserOfflineReason)reason {
    TTTUser *user = [self getUser:uid];
    if (!user) { return; }
    [[self getAVRegion:uid] closeRegion];
    [_users removeObject:user];
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine reportAudioLevel:(int64_t)userID audioLevel:(NSUInteger)audioLevel audioLevelFullRange:(NSUInteger)audioLevelFullRange {
    TTTUser *user = [self getUser:userID];
    if (!user) { return; }
    if (user.isAnchor) {
        [_voiceBtn setImage:[self getVoiceImage:audioLevel]];
    } else {
        [[self getAVRegion:userID] reportAudioLevel:audioLevel];
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine didAudioMuted:(BOOL)muted byUid:(int64_t)uid {
    TTTUser *user = [self getUser:uid];
    if (!user) { return; }
    user.mutedSelf = muted;
    [[self getAVRegion:uid] mutedSelf:muted];
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine localAudioStats:(TTTRtcLocalAudioStats *)stats {
    if (TTManager.me.isAnchor) {
        _audioStatsLabel.stringValue = [NSString stringWithFormat:@"A-↑%ldkbps", stats.sentBitrate];
    } else {
        [[self getAVRegion:TTManager.me.uid] setLocalAudioStats:stats.sentBitrate];
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine localVideoStats:(TTTRtcLocalVideoStats *)stats {
    if (TTManager.me.isAnchor) {
        _videoStatsLabel.stringValue = [NSString stringWithFormat:@"V-↑%ldkbps", stats.sentBitrate];
    } else {
        [[self getAVRegion:TTManager.me.uid] setLocalVideoStats:stats.sentBitrate];
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine remoteAudioStats:(TTTRtcRemoteAudioStats *)stats {
    TTTUser *user = [self getUser:stats.uid];
    if (!user) { return; }
    if (user.isAnchor) {
        _audioStatsLabel.stringValue = [NSString stringWithFormat:@"A-↓%ldkbps", stats.receivedBitrate];
    } else {
        [[self getAVRegion:stats.uid] setRemoterAudioStats:stats.receivedBitrate];
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine remoteVideoStats:(TTTRtcRemoteVideoStats *)stats {
    TTTUser *user = [self getUser:stats.uid];
    if (!user) { return; }
    if (user.isAnchor) {
        _videoStatsLabel.stringValue = [NSString stringWithFormat:@"V-↓%ldkbps", stats.receivedBitrate];
    } else {
        [[self getAVRegion:stats.uid] setRemoterVideoStats:stats.receivedBitrate];
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine firstRemoteVideoFrameDecodedOfUid:(int64_t)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    //解码远端用户第一帧
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine didLeaveChannelWithStats:(TTTRtcStats *)stats {
//    [engine stopPreview];
//    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)rtcEngineConnectionDidLost:(TTTRtcEngineKit *)engine {
    [self tipLeaveChannel:@"ConnectionDidLost"];
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine didKickedOutOfUid:(int64_t)uid reason:(TTTRtcKickedOutReason)reason {
    NSString *errorInfo = @"";
    switch (reason) {
        case TTTRtc_KickedOut_KickedByHost:
            errorInfo = @"被主播踢出";
            break;
        case TTTRtc_KickedOut_PushRtmpFailed:
            errorInfo = @"rtmp推流失败";
            break;
        case TTTRtc_KickedOut_MasterExit:
            errorInfo = @"主播已退出";
            break;
        case TTTRtc_KickedOut_ReLogin:
            errorInfo = @"重复登录";
            break;
        case TTTRtc_KickedOut_NoAudioData:
            errorInfo = @"长时间没有上行音频数据";
            break;
        case TTTRtc_KickedOut_NoVideoData:
            errorInfo = @"长时间没有上行视频数据";
            break;
        case TTTRtc_KickedOut_NewChairEnter:
            errorInfo = @"其他人以主播身份进入";
            break;
        case TTTRtc_KickedOut_ChannelKeyExpired:
            errorInfo = @"Channel Key失效";
            break;
        default:
            errorInfo = @"未知错误";
            break;
    }
    [self tipLeaveChannel:errorInfo];
}

- (void)tipLeaveChannel:(NSString *)tip {
    [TTManager.rtcEngine stopPreview];
    [TTManager.rtcEngine leaveChannel:nil];
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleCritical;
    alert.messageText = @"提示";
    alert.informativeText = tip;
    [alert addButtonWithTitle:@"确定"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        [TTManager.liveWindow close];
        TTManager.liveWindow = nil;
        [TTManager.loginWindow showWindow:nil];
    }];
}

#pragma mark - helper mehtod
- (AVRegionView *)getAVRegion:(int64_t)uid {
    __block AVRegionView *region = nil;
    [_avRegions enumerateObjectsUsingBlock:^(AVRegionView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.user.uid == uid) {
            region = obj;
            *stop = YES;
        }
    }];
    return region;
}

- (TTTUser *)getUser:(int64_t)uid {
    __block TTTUser *user = nil;
    [_users enumerateObjectsUsingBlock:^(TTTUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.uid == uid) {
            user = obj;
            *stop = YES;
        }
    }];
    return user;
}

- (void)refreshVideoCompositingLayout {
    TTTRtcVideoCompositingLayout *videoLayout = _videoLayout;
    if (!videoLayout) { return; }
    [videoLayout.regions removeAllObjects];
    TTTRtcVideoCompositingRegion *anchorRegion = [[TTTRtcVideoCompositingRegion alloc] init];
    anchorRegion.uid = TTManager.me.uid;
    anchorRegion.x = 0;
    anchorRegion.y = 0;
    anchorRegion.width = 1;
    anchorRegion.height = 1;
    anchorRegion.zOrder = 0;
    anchorRegion.alpha = 1;
    anchorRegion.renderMode = TTTRtc_Render_Adaptive;
    [videoLayout.regions addObject:anchorRegion];
    [_avRegions enumerateObjectsUsingBlock:^(AVRegionView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.user) {
            TTTRtcVideoCompositingRegion *videoRegion = [[TTTRtcVideoCompositingRegion alloc] init];
            videoRegion.uid = obj.user.uid;
            videoRegion.x = obj.videoPosition.x;
            videoRegion.y = obj.videoPosition.y;
            videoRegion.width = obj.videoPosition.w;
            videoRegion.height = obj.videoPosition.h;
            videoRegion.zOrder = 1;
            videoRegion.alpha = 1;
            videoRegion.renderMode = TTTRtc_Render_Adaptive;
            [videoLayout.regions addObject:videoRegion];
        }
    }];
    [TTManager.rtcEngine setVideoCompositingLayout:videoLayout];
}

- (AVRegionView *)positionAVRegion:(TTTVideoPosition *)position {
    __block AVRegionView *region = nil;
    [_avRegions enumerateObjectsUsingBlock:^(AVRegionView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (position.column == obj.videoPosition.column && position.row == obj.videoPosition.row) {
            region = obj;
            *stop = YES;
        }
    }];
    return region;
}

- (NSImage *)getVoiceImage:(NSUInteger)level {
    if (TTManager.me.mutedSelf && TTManager.me.isAnchor) {
        return [NSImage imageNamed:@"voice_close"];
    }
    NSImage *image = nil;
    if (level < 4) {
        image = [NSImage imageNamed:@"voice_small"];
    } else if (level < 7) {
        image = [NSImage imageNamed:@"voice_middle"];
    } else {
        image = [NSImage imageNamed:@"voice_big"];
    }
    return image;
}

@end
