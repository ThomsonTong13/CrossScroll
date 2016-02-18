//
//  THScrollView.m
//  CrossScroll
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "THScrollView.h"

#import "Utils.h"

@interface THScrollView () <UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) NSInteger totalPageCount;
@property (nonatomic, strong) NSMutableArray *contentViews;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong, readwrite) NSTimer *animationTimer;
@property (nonatomic, assign, readwrite) NSTimeInterval animationDuration;

@end

@implementation THScrollView

#pragma mark - Lifecycle

- (instancetype)initWithAnimationDuration:(NSTimeInterval)animationDuration
{
    self = [self init];

    if (animationDuration > 0.f)
    {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(self.animationDuration = animationDuration)
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
                                                              repeats:YES];
    }

    return self;
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.currentPageIndex = 0;
        self.clipsToBounds = YES;

        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.contentView];

        UIImageView *coverImageView = [UIImageView new];
        coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        coverImageView.image = [UIImage imageNamed:@"activity_cover"];
        [self addSubview:coverImageView];

        @weakify(self);
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {

            @strongify(self);
            make.edges.equalTo(self);
        }];

        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {

            @strongify(self);
            make.edges.equalTo(self.scrollView);
            make.height.equalTo(self.scrollView);
        }];

        [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {

            @strongify(self);
            make.left.and.right.and.top.equalTo(self);
        }];

        [[RACObserve(self, imagesArray)
          filter:^BOOL(id value) {

              return value != nil;
          }]
          subscribeNext:^(NSArray *ads) {

              @strongify(self);
              self.totalPageCount = ads.count;
              [self configContentViews:NO];
          }];

        [[self
          rac_signalForSelector:@selector(scrollViewWillBeginDragging:)
          fromProtocol:@protocol(UIScrollViewDelegate)]
          subscribeNext:^(RACTuple *tuple) {

              @strongify(self);
              [self.animationTimer pauseTimer];
          }];
        
        [[self
          rac_signalForSelector:@selector(scrollViewDidEndDragging:willDecelerate:)
          fromProtocol:@protocol(UIScrollViewDelegate)]
          subscribeNext:^(RACTuple *tuple) {

              @strongify(self);
              [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
          }];
        
        [[self
          rac_signalForSelector:@selector(scrollViewDidEndDecelerating:)
          fromProtocol:@protocol(UIScrollViewDelegate)]
          subscribeNext:^(RACTuple *tuple) {

              UIScrollView *scrollView = tuple.first;
              [scrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:YES];
          }];
        
        [[self
          rac_signalForSelector:@selector(scrollViewDidScroll:)
          fromProtocol:@protocol(UIScrollViewDelegate)]
          subscribeNext:^(RACTuple *tuple) {

              @strongify(self);

              UIScrollView *scrollView = tuple.first;
              int contentOffsetX = scrollView.contentOffset.x;

              if(contentOffsetX >= (2 * kScreenWidth))
              {
                  self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
                  [self configContentViews:NO];
              }

              if(contentOffsetX <= 0)
              {
                  self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
                  [self configContentViews:YES];
              }

              CGPoint offset = scrollView.contentOffset;
              offset.y = 0;
              scrollView.contentOffset = offset;
          }];

        self.scrollView.delegate = nil;
        self.scrollView.delegate = self;
    }

    return self;
}

- (void)dealloc
{
}

- (void)setImageFrame:(CGRect)frame
{
    NSDictionary *dictionary = self.contentViews[1];
    UIView *contentView = dictionary[@"imageView"];

    for (MASLayoutConstraint *constraint in self.contentView.constraints)
    {
        if (constraint.firstItem == contentView && constraint.firstAttribute == NSLayoutAttributeLeft)
        {
            constraint.constant = frame.origin.x;
        }
    }

    for (MASLayoutConstraint *constraint in contentView.constraints)
    {
        if (constraint.firstAttribute == NSLayoutAttributeWidth)
        {
            constraint.constant = frame.size.width - frame.origin.x;
        }

        if (constraint.firstAttribute == NSLayoutAttributeHeight)
        {
            constraint.constant = frame.size.height;
        }
    }
}

#pragma mark - Event Response

- (void)animationTimerDidFired:(NSTimer *)timer
{
    CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x + kScreenWidth, self.scrollView.contentOffset.y);

    [self.scrollView setContentOffset:newOffset animated:YES];
}

#pragma mark - public methods

- (void)configContentViews:(BOOL)isLeft
{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewContentDataSource:isLeft];

    UIView *lastView = nil;

    for (NSDictionary *dictionary in self.contentViews)
    {
        UIView *contentView = dictionary[@"imageView"];
        [self.contentView addSubview:contentView];

        [MASLayoutConstraint deactivateConstraints:contentView.constraints];

        @weakify(self);
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {

            @strongify(self);
            make.left.equalTo(lastView ? lastView.mas_right : self.contentView.mas_left);
            make.top.equalTo(self.contentView);
            make.width.equalTo(@(kScreenWidth));
            make.height.equalTo(@(kScrollViewHeight));
        }];

        lastView = contentView;
    }

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.right.equalTo(lastView.mas_right);
    }];

    CGFloat offset = kScreenWidth;
    [_scrollView setContentOffset:CGPointMake(offset, 0)];
}

#pragma mark - Private Methods

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1)
    {
        return self.totalPageCount - 1;
    }
    else if (currentPageIndex == self.totalPageCount)
    {
        return 0;
    }
    else
    {
        return currentPageIndex;
    }
}

/**
 *  设置scrollView的content数据源，即contentViews
 */
- (void)setScrollViewContentDataSource:(BOOL)isLeft
{
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];

    if (self.contentViews.count == 0)
    {
        [self.contentViews addObject:self.imagesArray[previousPageIndex]];
        [self.contentViews addObject:self.imagesArray[self.currentPageIndex]];
        [self.contentViews addObject:self.imagesArray[rearPageIndex]];
    }
    else
    {
        if (isLeft)
        {
            [self.contentViews removeLastObject];
            [self.contentViews insertObject:self.imagesArray[previousPageIndex] atIndex:0];
        }
        else
        {
            [self.contentViews removeObjectAtIndex:0];
            [self.contentViews addObject:self.imagesArray[rearPageIndex]];
        }
    }
}

- (void)resumeTimer
{
    [self configContentViews:NO];
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
}

#pragma mark - getters and setters

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [UIScrollView new];

        _scrollView.contentMode = UIViewContentModeCenter;
        _scrollView.contentSize = CGSizeMake(3*kScreenWidth, kScrollViewHeight);
        _scrollView.contentOffset = CGPointMake(0, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.clipsToBounds = YES;
    }

    return _scrollView;
}

- (UIView *)contentView
{
    if (!_contentView)
    {
        _contentView = [UIView new];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.clipsToBounds = YES;
    }

    return _contentView;
}

- (NSMutableArray *)contentViews
{
    if (!_contentViews) _contentViews = [NSMutableArray new];

    return _contentViews;
}

@end
