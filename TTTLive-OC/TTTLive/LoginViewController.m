//
//  LoginViewController.m
//  TTTLive
//
//  Created by yanzhen on 2018/9/26.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "LoginViewController.h"
#import "LiveWindowController.h"
#import "TTTProgressHud.h"
#import "NSView+Toast.h"
#import "TTTRtcManager.h"

@interface LoginViewController ()<TTTRtcEngineDelegate>
@property (weak) NSButton *roleSelectedBtn;
@property (weak) IBOutlet NSButton *anchorBtn;
@property (weak) IBOutlet NSButton *broadcasterBtn;
@property (weak) IBOutlet NSTextField *roomIDTF;
@property (weak) IBOutlet NSButton *loginBtn;
@property (weak) IBOutlet NSTextField *websiteLabel;
@property (assign) int64_t uid;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    _uid = arc4random() % 100000 + 1;
    int64_t roomID = [[NSUserDefaults standardUserDefaults] stringForKey:@"ENTERROOMID"].integerValue;
    if (roomID == 0) {
        roomID = arc4random() % 1000000 + 1;
    }
    _roomIDTF.stringValue = [NSString stringWithFormat:@"%lld", roomID];
}

- (IBAction)enterChannel:(id)sender {
    if (_roomIDTF.stringValue.length == 0 || _roomIDTF.stringValue.length >= 19 || _roomIDTF.stringValue.longLongValue <= 0) {
        [self showToast:@"请输入19位以内的房间ID"];
        return;
    }
    [NSUserDefaults.standardUserDefaults setValue:_roomIDTF.stringValue forKey:@"ENTERROOMID"];
    [NSUserDefaults.standardUserDefaults synchronize];
    [TTTProgressHud showHud:self.view];
    
    TTTRtcClientRole role = _roleSelectedBtn.tag;
    TTManager.roomID = _roomIDTF.integerValue;
    TTManager.me.uid = _uid;
    TTManager.me.clientRole = role;
    
    TTManager.rtcEngine.delegate = self;
    
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *test = (NSString *)kCFBundleExecutableKey;
    NSString *logFileName = NSBundle.mainBundle.infoDictionary[test] ;
    logFileName = [documentsDirectory stringByAppendingFormat:@"/%@.log", logFileName];
    
    [TTManager.rtcEngine setLogFile:logFileName];
    [TTManager.rtcEngine setLogFilter:TTTRtc_LogFilter_Debug];
    
    [TTManager.rtcEngine setChannelProfile:TTTRtc_ChannelProfile_LiveBroadcasting];
    [TTManager.rtcEngine setClientRole:role withKey:nil];
    [TTManager.rtcEngine enableAudioVolumeIndication:200 smooth:3];
    if (role == TTTRtc_ClientRole_Anchor) {
        [TTManager.rtcEngine enableVideo];
        [TTManager.rtcEngine muteLocalAudioStream:NO];
        [TTManager.rtcEngine setVideoProfile:TTTRtc_VideoProfile_360P swapWidthAndHeight:NO];
        
        TTTPublisherConfigurationBuilder *builder = [[TTTPublisherConfigurationBuilder alloc] init];
        NSString *pushURL = [NSString stringWithFormat:@"rtmp://push.3ttech.cn/sdk/%@", _roomIDTF.stringValue];
        [builder setPublisherUrl:pushURL];
        [TTManager.rtcEngine configPublisher:[builder build]];
    } else if (role == TTTRtc_ClientRole_Broadcaster) {
        [TTManager.rtcEngine enableVideo];
        [TTManager.rtcEngine muteLocalAudioStream:NO];
        [TTManager.rtcEngine setVideoProfile:TTTRtc_VideoProfile_360P swapWidthAndHeight:NO];
    }
    [TTManager.rtcEngine joinChannelByKey:nil channelName:_roomIDTF.stringValue uid:_uid joinSuccess:nil];
}

- (IBAction)selectedRoleAction:(NSButton *)sender {
    if (sender == _roleSelectedBtn) { return; }
    BOOL isAnchor = sender.tag == 1;
    sender.layer.backgroundColor = NSColor.cyanColor.CGColor;
    [sender setTitle:isAnchor ? @"主播" : @"副播"];
    _roleSelectedBtn.layer.backgroundColor = NSColor.blackColor.CGColor;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:isAnchor ? @"副播" : @"主播" attributes:@{NSForegroundColorAttributeName : NSColor.whiteColor, NSFontSizeAttribute : [NSFont systemFontOfSize:12]}];
    [str setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, 2)];
    [_roleSelectedBtn setAttributedTitle:str];
    _roleSelectedBtn = sender;
}


- (void)configureUI {
    NSString *websitePrefix = @"http://www.3ttech.cn  ";
    _websiteLabel.stringValue = [websitePrefix stringByAppendingString:TTTRtcEngineKit.getSdkVersion];
    
    _roleSelectedBtn = _anchorBtn;
    
    _anchorBtn.alphaValue = 0.6;
    _anchorBtn.wantsLayer = YES;
    _anchorBtn.layer.backgroundColor = NSColor.cyanColor.CGColor;
    
    _broadcasterBtn.alphaValue = 0.6;
    _broadcasterBtn.wantsLayer = YES;
    _broadcasterBtn.layer.backgroundColor = NSColor.blackColor.CGColor;
    NSMutableAttributedString *bro = [[NSMutableAttributedString alloc] initWithString:@"副播" attributes:@{NSForegroundColorAttributeName : NSColor.whiteColor, NSFontSizeAttribute : [NSFont systemFontOfSize:12]}];
    [bro setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, 2)];
    [_broadcasterBtn setAttributedTitle:bro];
    
    //loginBtn
    NSColor *textColor = [NSColor colorWithRed:36 / 255.0 green:182 / 255.0 blue:202 / 255.0 alpha:1];
    _loginBtn.layer.backgroundColor = textColor.CGColor;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"进入房间" attributes:@{NSForegroundColorAttributeName : NSColor.whiteColor, NSFontSizeAttribute : [NSFont systemFontOfSize:18]}];
    [string setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, 4)];
    [_loginBtn setAttributedTitle:string];
}

#pragma mark - TTTRtcEngineDelegate
- (void)rtcEngine:(TTTRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(int64_t)uid elapsed:(NSInteger)elapsed {
    [TTTProgressHud hideHud:self.view];
    TTManager.loginWindow = self.view.window.windowController;
    LiveWindowController *window = [self.storyboard instantiateControllerWithIdentifier:@"Live"];
    TTManager.liveWindow = window;
    [window showWindow:self];
    [TTManager.loginWindow close];
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine didOccurError:(TTTRtcErrorCode)errorCode {
    NSString *errorInfo = @"";
    switch (errorCode) {
        case TTTRtc_Error_Enter_TimeOut:
            errorInfo = @"超时,10秒未收到服务器返回结果";
            break;
        case TTTRtc_Error_Enter_Failed:
            errorInfo = @"该直播间不存在";
            break;
        case TTTRtc_Error_Enter_BadVersion:
            errorInfo = @"版本错误";
            break;
        case TTTRtc_Error_InvalidChannelName:
            errorInfo = @"Invalid channel name";
            break;
        default:
            errorInfo = [NSString stringWithFormat:@"未知错误：%zd",errorCode];
            break;
    }
    [TTTProgressHud hideHud:self.view];
    [self showToast:errorInfo];
}
@end
