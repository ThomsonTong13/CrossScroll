//
//  THHeaderView.m
//  CrossScroll
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "THHeaderView.h"
#import "THScrollView.h"
#import "THClickableImageView.h"

#import "Utils.h"

@interface THHeaderView ()

@property (nonatomic, strong) THScrollView *periodView;

@end

@implementation THHeaderView

#pragma mark - Lifecycle

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];

    NSArray *images = @[
                        @"http://ww3.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr0nly5j20pf0gygo6.jpg",
                        @"http://ww4.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr1d0vyj20pf0gytcj.jpg",
                        @"http://ww3.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg",
                        @"http://ww2.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg",
                        @"http://ww2.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr39ht9j20gy0o6q74.jpg",
                        @"http://ww3.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr3xvtlj20gy0obadv.jpg",
                        @"http://ww4.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
                        @"http://ww3.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg"
                        ];

    NSMutableArray *imagesM = [[NSMutableArray alloc] initWithCapacity:0];

    @weakify(self);

    for (int index = 0; index < images.count; index ++)
    {
        NSString *URLString = images[index];

        THClickableImageView *imageView = [[THClickableImageView alloc] initWithRACCommand:[[RACCommand alloc]
                                                                                            initWithSignalBlock:^RACSignal *(id input) {

                                                                                                NSLog(@"%@", URLString);

                                                                                                return [RACSignal empty];
                                                                                            }]];
        [imageView sd_setImageWithURL:[NSURL URLWithString:URLString]];

        NSDictionary *dictionary = @{ @"imageView" : imageView };
        [imagesM addObject:dictionary];
    }

    self.periodView = [[THScrollView alloc] initWithAnimationDuration:5.0];
    self.periodView.imagesArray = [[NSArray alloc] initWithArray:imagesM];

    [self addSubview:self.periodView];

    [self.periodView mas_makeConstraints:^(MASConstraintMaker *make) {

        @strongify(self);
        make.edges.equalTo(self);
    }];
}

#pragma mark - Override Methods

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    self.periodView.userInteractionEnabled = userInteractionEnabled;
}

@end
