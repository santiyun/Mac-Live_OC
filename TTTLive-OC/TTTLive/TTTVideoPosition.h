//
//  TTTVideoPosition.h
//  TTTLive
//
//  Created by yanzhen on 2018/10/11.
//  Copyright © 2018年 yanzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTTVideoPosition : NSObject
@property double x;
@property double y;
@property double w;
@property double h;
@property (readonly) int row;
@property (readonly) int column;
@end
