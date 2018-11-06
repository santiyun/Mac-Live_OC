//
//  AVRegionView.m
//  TTTLive
//
//  Created by yanzhen on 2018/9/30.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "AVRegionView.h"
#import <TTTRtcEngineKit/TTTRtcEngineKit.h>
#import "TTTRtcManager.h"
#import "TTTVideoPosition.h"
#import "TTTUser.h"

@interface AVRegionView ()
@property (strong) IBOutlet NSView *backgroundView;
@property (weak) IBOutlet NSImageView *videoPlayer;
@property (weak) IBOutlet NSButton *voiceBtn;
@property (weak) IBOutlet NSTextField *idLabel;
@property (weak) IBOutlet NSTextField *audioStatsLabel;
@property (weak) IBOutlet NSTextField *videoStatsLabel;

@end

@implementation AVRegionView

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"AVRegionView" owner:self topLevelObjects:nil];
        _backgroundView.frame = self.bounds;
        [self addSubview:_backgroundView];
        _backgroundView.alphaValue = 0.7;
        
        _videoPosition = [[TTTVideoPosition alloc] init];
        CGRect convertFrame = [self.superview convertRect:self.frame toView:self.superview.superview];
        
        CGFloat width = 853;
        CGFloat height = 480;
        convertFrame.origin.y = height - convertFrame.origin.y - convertFrame.size.height;
        _videoPosition.x = convertFrame.origin.x / width;
        _videoPosition.y = convertFrame.origin.y / height;
        _videoPosition.w = self.frame.size.width / width;
        _videoPosition.h = self.frame.size.height / height;
    }
    return self;
}

- (IBAction)enableVoiceAction:(NSButton *)sender {
    if (TTManager.me != _user) { return; }
    if (sender.tag == 0) {
        sender.tag = 1;
        _user.mutedSelf = YES;
    } else {
        sender.tag = 0;
        _user.mutedSelf = NO;
    }
    [TTManager.rtcEngine muteLocalAudioStream:_user.mutedSelf];
    [_voiceBtn setImage:[NSImage imageNamed:_user.mutedSelf ? @"voice_close" : @"voice_small"]];
}


- (NSImage *)getVoiceImage:(NSUInteger)audioLevel {
    NSImage *image = nil;
    if (audioLevel < 4) {
        image = [NSImage imageNamed:@"voice_small"];
    } else if (audioLevel < 7) {
        image = [NSImage imageNamed:@"voice_middle"];
    } else {
        image = [NSImage imageNamed:@"voice_big"];
    }
    return image;
}

#pragma mark - public
- (void)configureRegion:(TTTUser *)user {
    self.user = user;
    _backgroundView.alphaValue = 1;
    [_voiceBtn setImage:[NSImage imageNamed:@"voice_small"]];
    _idLabel.hidden = NO;
    _voiceBtn.hidden = NO;
    _audioStatsLabel.hidden = NO;
    _videoStatsLabel.hidden = NO;
    _idLabel.integerValue = user.uid;
    
    TTTRtcVideoCanvas *videoCanvas = [[TTTRtcVideoCanvas alloc] init];
    videoCanvas.uid = user.uid;
    videoCanvas.renderMode = TTTRtc_Render_Adaptive;
    videoCanvas.view = _videoPlayer;
    if (TTManager.me == user) {
        [TTManager.rtcEngine setupLocalVideo:videoCanvas];
    } else {
        [TTManager.rtcEngine setupRemoteVideo:videoCanvas];
        if (user.mutedSelf) {
            [self mutedSelf:YES];
        }
    }
}

- (void)closeRegion {
    _backgroundView.alphaValue = 0.7;
    _idLabel.hidden = YES;
    _voiceBtn.hidden = YES;
    _audioStatsLabel.hidden = YES;
    _videoStatsLabel.hidden = YES;
    _videoPlayer.image = [NSImage imageNamed:@"live_head"];
    _user = nil;
}

- (void)reportAudioLevel:(NSUInteger)level {
    if (_user.mutedSelf) { return; }
    [_voiceBtn setImage:[self getVoiceImage:level]];
}

- (void)setLocalAudioStats:(NSUInteger)stats {
    _audioStatsLabel.stringValue = [NSString stringWithFormat:@"A-↑%lukbps",(unsigned long)stats];
}

- (void)setLocalVideoStats:(NSUInteger)stats {
    _videoStatsLabel.stringValue = [NSString stringWithFormat:@"V-↑%lukbps",(unsigned long)stats];
}

- (void)setRemoterAudioStats:(NSUInteger)stats {
    _audioStatsLabel.stringValue = [NSString stringWithFormat:@"A-↓%lukbps",(unsigned long)stats];
}

- (void)setRemoterVideoStats:(NSUInteger)stats {
    _videoStatsLabel.stringValue = [NSString stringWithFormat:@"V-↓%lukbps",(unsigned long)stats];
}

- (void)mutedSelf:(BOOL)mute {
    [_voiceBtn setImage:[NSImage imageNamed:mute ? @"speaking_closed" : @"voice_small"]];
}
@end
