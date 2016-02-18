//
//  THClickableImageView.h
//  CrossScroll
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACCommand;

@interface THClickableImageView : UIImageView

@property (nonatomic, strong) NSString *name;

- (instancetype)initWithRACCommand:(RACCommand *)rac_command;

@end
