//
//  THClickableImageView.m
//  CrossScroll
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "THClickableImageView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface THClickableImageView ()

@property (nonatomic, strong) RACCommand *rac_command;

@end

@implementation THClickableImageView

- (instancetype)initWithRACCommand:(RACCommand *)rac_command
{
    _rac_command = rac_command;

    return [self init];
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;

        UITapGestureRecognizer *onTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageTapped:)];
        [self addGestureRecognizer:onTap];
    }

    return self;
}

- (void)onImageTapped:(UIGestureRecognizer *)recognizer
{
    if (self.rac_command)
    {
        [self.rac_command execute:self];
    }
}

- (NSString *)description
{
    return self.name;
}

@end
