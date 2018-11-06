//
//  TTTProgressHud.m
//  YZ
//
//  Created by yanzhen on 2018/9/6.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "TTTProgressHud.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat TTHudMinWH = 80;
static const CGFloat TTHudShowViewCornerRadius = 5;
static const CGFloat TTHudTitleFontSize = 16;
static const CGFloat TTHudTakeMax = 0.7;
static const CGFloat TTHudPadding = 15;

@interface TTTProgressHud ()
@property (strong) NSView *showView;
@end

@implementation TTTProgressHud

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
        _showView = [[NSView alloc] init];
        _showView.wantsLayer = YES;
        _showView.layer.backgroundColor = [NSColor colorWithWhite:0.8 alpha:0.6].CGColor;
        _showView.frame = CGRectMake(0, 0, TTHudMinWH, TTHudMinWH);
        _showView.layer.masksToBounds = YES;
        _showView.layer.cornerRadius = TTHudShowViewCornerRadius;
        [self addSubview:_showView];
    }
    return self;
}

- (void)mouseDown:(NSEvent *)event {
    //阻挡事件响应
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    [self adjustView:_showView inView:self];
    
}

- (void)adjustView:(NSView *)small inView:(NSView *)big {
    CGFloat showW = small.bounds.size.width;
    CGFloat showH = small.bounds.size.height;
    small.frame = CGRectMake((big.bounds.size.width - showW) * 0.5, (big.bounds.size.height - showH) * 0.5, showW, showH);
}

- (void)adjustShowViewFrame {
    CGFloat showW = _showView.bounds.size.width;
    CGFloat showH = _showView.bounds.size.height;
    _showView.frame = CGRectMake((self.bounds.size.width - showW) * 0.5, (self.bounds.size.height - showH) * 0.5, showW, showH);
}

+ (void)showHud:(NSView *)view {
    [self showHud:view message:nil];
}

+ (void)showHud:(NSView *)view message:(NSString *)message {
    [self showHud:view message:message textColor:nil];
}

+ (void)showHud:(NSView *)view message:(NSString *)message textColor:(NSColor *)color {
    [self hideHud:view];
    TTTProgressHud *hud = [[TTTProgressHud alloc] initWithFrame:view.bounds];
    [hud create:message textColor:color];
    [view addSubview:hud];
}

#pragma mark - private

- (void)create:(NSString *)message textColor:(NSColor *)color {
    if (message.length == 0) {
        NSProgressIndicator *indicator = [self createIndicator];
        [_showView addSubview:indicator];
        [self adjustView:_showView inView:self];
        [self adjustView:indicator inView:_showView];
        return;
    }
    NSProgressIndicator *indicator = [self createIndicator];
    [_showView addSubview:indicator];
    [self adjustViewAndAddTitleLabel:indicator message:message textColor:color];
}

- (void)adjustViewAndAddTitleLabel:(NSView *)view message:(NSString *)message textColor:(NSColor *)color {
    NSTextField *titleLabel = [self createTitleLabel];
    [_showView addSubview:titleLabel];
    titleLabel.stringValue = message;
    if (color) {
        titleLabel.textColor = color;
    }

    CGSize maxSize = CGSizeMake(self.bounds.size.width * TTHudTakeMax, self.bounds.size.height * TTHudTakeMax);
    CGSize textSize = [message boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : titleLabel.font} context:nil].size;
    CGFloat showW = textSize.width + 5 + TTHudPadding * 2;
    if (showW < TTHudMinWH) {
        showW = TTHudMinWH;
    }
    CGFloat showH = TTHudPadding + view.frame.size.height + TTHudPadding * 2.34;
    _showView.frame = CGRectMake(0, 0, showW, showH);
    [self adjustView:_showView inView:self];
    view.frame = CGRectMake((showW - view.bounds.size.width) * 0.5, showH - TTHudPadding - view.bounds.size.height, view.bounds.size.width, view.bounds.size.height);
    titleLabel.frame = CGRectMake(TTHudPadding, TTHudPadding - 5, showW - TTHudPadding * 2, TTHudPadding + 2);
}

- (NSTextField *)createTitleLabel {
    NSTextField *titleLabel = [[NSTextField alloc] init];
    titleLabel.bordered = NO;
    titleLabel.editable = NO;
    titleLabel.backgroundColor = NSColor.clearColor;
    titleLabel.alignment = NSTextAlignmentCenter;
    titleLabel.textColor = NSColor.blackColor;
    titleLabel.font = [NSFont systemFontOfSize:TTHudTitleFontSize];
    return titleLabel;
}

- (NSProgressIndicator *)createIndicator {
    NSProgressIndicator *indicator = [[NSProgressIndicator alloc] init];
    indicator.frame = CGRectMake(0, 0, 32, 32);
    indicator.style = NSProgressIndicatorStyleSpinning;
    indicator.controlSize = NSControlSizeRegular;
    [indicator startAnimation:nil];
    return indicator;
}

+ (void)hideHud:(NSView *)view {
    [view.subviews enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTTProgressHud class]]) {
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                context.duration = 0.5;
                [[obj animator] setAlphaValue:0];
            } completionHandler:^{
                [obj removeFromSuperview];
            }];
        }
    }];
}
@end
