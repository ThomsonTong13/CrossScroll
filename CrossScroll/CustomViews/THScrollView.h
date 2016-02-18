//
//  THScrollView.h
//  CrossScroll
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSTimer+Addition.h"

static NSInteger kScrollViewHeight = 300;

@interface THScrollView : UIView

@property (nonatomic, strong, readonly) NSTimer *animationTimer;
@property (nonatomic, assign, readonly) NSTimeInterval animationDuration;

@property (nonatomic, strong) NSArray *imagesArray;

/**
 *  初始化
 *
 *  @param frame             frame
 *  @param animationDuration 自动滚动的间隔时长。如果<=0，不自动滚动。
 *
 *  @return instance
 */
- (instancetype)initWithAnimationDuration:(NSTimeInterval)animationDuration;
- (void)setImageFrame:(CGRect)frame;

@end
