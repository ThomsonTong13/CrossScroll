//
//  NSTimer+Addition.h
//  Miban
//
//  Created by Thomson on 15/7/13.
//  Copyright (c) 2015年 Kemi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Addition)

- (void)pauseTimer;
- (void)resumeTimer;
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;

@end
