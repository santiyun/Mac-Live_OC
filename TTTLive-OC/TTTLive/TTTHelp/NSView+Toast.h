//
//  NSView+Toast.h
//  YZ
//
//  Created by yanzhen on 2018/9/6.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Toast)
@property (assign) IBInspectable CGFloat borderWidth;
@property (strong) IBInspectable NSColor *borderColor;
@property (assign) IBInspectable CGFloat cornerRadius;

- (void)showToast:(NSString *)message;
- (void)showToast:(NSString *)message duration:(NSTimeInterval)duration;
- (void)showTopToast:(NSString *)message;
- (void)showTopToast:(NSString *)message duration:(NSTimeInterval)duration;
- (void)showBottomToast:(NSString *)message;
- (void)showBottomToast:(NSString *)message duration:(NSTimeInterval)duration;
@end

@interface NSViewController (Toast)
- (void)showToast:(NSString *)message;
@end
