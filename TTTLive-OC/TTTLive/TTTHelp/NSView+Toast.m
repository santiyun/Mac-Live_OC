//
//  NSView+Toast.m
//  YZ
//
//  Created by yanzhen on 2018/9/6.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import "NSView+Toast.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const TTToastTopPadding = 74;
static CGFloat const TTToastHorizontalPadding = 10;
static CGFloat const TTToastVerticalPadding = 10;
static NSTimeInterval const TTToastDefaultDuration = 2.5;

static CGFloat const TTToastShadowRadius = 6;
static CGSize const TTToastShadowOffset = {4, 4};
static CGFloat const TTToastFontSize = 16;
static CGFloat const TTToastCornerRadius = 3;

typedef enum : NSUInteger {
    ToastTypeCenter,
    ToastTypeTop,
    ToastTypeBottom,
} ToastType;

@implementation NSView (Toast)
- (void)showToast:(NSString *)message {
    [self showToast:message duration:TTToastDefaultDuration position:ToastTypeCenter];
}

- (void)showToast:(NSString *)message duration:(NSTimeInterval)duration {
    [self showToast:message duration:duration position:ToastTypeCenter];
}

- (void)showTopToast:(NSString *)message {
    [self showToast:message duration:TTToastDefaultDuration position:ToastTypeTop];
}

- (void)showTopToast:(NSString *)message duration:(NSTimeInterval)duration {
    [self showToast:message duration:duration position:ToastTypeTop];
}

- (void)showBottomToast:(NSString *)message {
    [self showToast:message duration:TTToastDefaultDuration position:ToastTypeBottom];
}

- (void)showBottomToast:(NSString *)message duration:(NSTimeInterval)duration {
    [self showToast:message duration:duration position:ToastTypeBottom];
}
#pragma mark - private toast
#pragma mark - private
- (void)showToast:(NSString *)message duration:(NSTimeInterval)duration position:(ToastType)position {
    NSView *toast = [self viewForMessage:message];
    [self showToastView:toast duration:duration position:position];
}

- (void)showToastView:(NSView *)toast duration:(NSTimeInterval)duration position:(ToastType)position {
    [self makeToastCenter:toast type:position];
    [self addSubview:toast];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            context.duration = 0.5;
            [[toast animator] setAlphaValue:0];
        } completionHandler:^{
            [toast removeFromSuperview];
        }];
    });
}

- (void)makeToastCenter:(NSView *)toast type:(ToastType)type {
    CGFloat centerX = self.bounds.size.width * 0.5;
    CGFloat toastY = 0;
    CGFloat toastH = toast.frame.size.height;
    switch (type) {
        case ToastTypeTop:
            toastY = self.bounds.size.height - TTToastTopPadding - toastH;
            break;
        case ToastTypeBottom:
            toastY = TTToastTopPadding;
            break;
        default:
            toastY = (self.bounds.size.height - toastH) * 0.5;
            break;
    }
    toast.frame = CGRectMake(centerX - toast.bounds.size.width * 0.5, toastY, toast.bounds.size.width, toastH);
}

- (NSView *)viewForMessage:(NSString *)message {
    NSView *toast = [[NSView alloc] init];
    toast.wantsLayer = YES;
    toast.layer.backgroundColor = NSColor.blackColor.CGColor;
    toast.layer.cornerRadius = TTToastCornerRadius;
    toast.layer.shadowColor = NSColor.blackColor.CGColor;
    toast.layer.shadowOpacity = 1;
    toast.layer.shadowRadius = TTToastShadowRadius;
    toast.layer.shadowOffset = TTToastShadowOffset;
    //
    NSTextField *messageLabel = [[NSTextField alloc] init];
    messageLabel.editable = NO;
    messageLabel.bezeled = NO;
    messageLabel.drawsBackground = NO;
    NSFont *font = [NSFont systemFontOfSize:TTToastFontSize];
    messageLabel.font = font;
    messageLabel.textColor = NSColor.whiteColor;
    messageLabel.stringValue = message;
    
    CGSize maxSize = CGSizeMake(self.bounds.size.width * 0.8, self.bounds.size.height * 0.8);
    CGSize messageSize = [message boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    messageLabel.frame = CGRectMake(TTToastHorizontalPadding, TTToastVerticalPadding, messageSize.width + 5, messageSize.height);
    toast.frame = CGRectMake(0, 0, messageSize.width + 5 + 2 * TTToastHorizontalPadding, messageSize.height + 2 * TTToastVerticalPadding);
    [toast addSubview:messageLabel];
    return toast;
}

#pragma mark - for xib 
- (void)setBorderWidth:(CGFloat)borderWidth {
    self.wantsLayer = YES;
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth {
    return 0;
}

- (void)setBorderColor:(NSColor *)borderColor {
    self.wantsLayer = YES;
    self.layer.borderColor = borderColor.CGColor;
}

- (NSColor *)borderColor {
    return NSColor.redColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.wantsLayer = YES;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius {
    return 0;
}
@end

@implementation NSViewController (Toast)
- (void)showToast:(NSString *)message {
    [self.view showToast:message];
}
@end
