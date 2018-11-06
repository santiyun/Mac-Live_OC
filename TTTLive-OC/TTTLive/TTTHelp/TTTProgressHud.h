//
//  TTTProgressHud.h
//  YZ
//
//  Created by yanzhen on 2018/9/6.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TTTProgressHud : NSView
+ (void)showHud:(NSView *)view;
+ (void)showHud:(NSView *)view message:(NSString *)message;
+ (void)showHud:(NSView *)view message:(NSString *)message textColor:(NSColor *)color;

+ (void)hideHud:(NSView *)view;
@end
