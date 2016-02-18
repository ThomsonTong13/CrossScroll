//
//  NSTimer+Addition.m
//  Miban
//
//  Created by Thomson on 15/7/13.
//  Copyright (c) 2015年 Kemi. All rights reserved.
//

#import "NSTimer+Addition.h"

@implementation NSTimer (Addition)

- (void)pauseTimer
{
    if (![self isValid]) return;

    [self setFireDate:[NSDate distantFuture]];
}


- (void)resumeTimer
{
    if (![self isValid]) return;

    [self setFireDate:[NSDate date]];
}

- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval
{
    if (![self isValid]) return;

    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

@end
