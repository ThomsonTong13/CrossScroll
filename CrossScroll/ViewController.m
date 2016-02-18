//
//  ViewController.m
//  CrossScroll
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "ViewController.h"

#import "THHeaderView.h"
#import "THScrollView.h"

#import "Utils.h"

#define defaultOffsetMultiple 0.6

@interface ViewController () <UIScrollViewDelegate>
{
    BOOL _didInited;
}

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet THHeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *navigationBar;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *praiseButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;

@property (weak, nonatomic) IBOutlet UIImageView *collectionImageView;
@property (weak, nonatomic) IBOutlet UILabel *collectionText;

@property (weak, nonatomic) IBOutlet UIButton *focusButton;

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@property (weak, nonatomic) IBOutlet UIView *joinBackgroundView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTopConstraint;

@property (nonatomic, assign) CGRect targetViewOriginFrame;

@property (nonatomic, assign) BOOL isWish;
@property (nonatomic, strong) NSArray *join;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configViews];

    [self setupActionBinds];

    self.join = @[
                  @"",
                  @""
                  ];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        const CGFloat defaultWebViewHeight = 22.0;

        CGSize actualSize = [webView sizeThatFits:CGSizeZero];
        if (actualSize.height <= defaultWebViewHeight) actualSize.height = defaultWebViewHeight;

        self.webViewHeightConstraint.constant = actualSize.height;
    });
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    THScrollView *thScrollView = [self.headerView.subviews firstObject];
    [thScrollView.animationTimer pauseTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_didInited)
    {
        _targetViewOriginFrame = self.headerView.frame;
        _didInited = YES;
    }

    CGFloat offsetY = scrollView.contentOffset.y;

    if (offsetY > 0)
    {
        CGFloat increment = offsetY * defaultOffsetMultiple;
        self.headerViewTopConstraint.constant = _targetViewOriginFrame.origin.y - increment;
        self.headerViewHeightConstraint.constant = _targetViewOriginFrame.size.height - (offsetY -increment);

        self.headerView.userInteractionEnabled = YES;
    }
    else if (offsetY == 0)
    {
        self.headerViewTopConstraint.constant = 0;
        self.headerViewHeightConstraint.constant = _targetViewOriginFrame.size.height;
        self.headerViewLeadingConstraint.constant = self.headerViewTailingConstraint.constant = 0;

        THScrollView *thScrollView = [self.headerView.subviews firstObject];
        [thScrollView setImageFrame:CGRectMake(0, 0, _targetViewOriginFrame.size.width, _targetViewOriginFrame.size.height)];

        self.headerView.userInteractionEnabled = YES;
    }
    else
    {
        CGFloat heigth = _targetViewOriginFrame.size.height + ABS(offsetY);
        CGFloat width  = heigth * _targetViewOriginFrame.size.width / _targetViewOriginFrame.size.height;
        CGFloat x      = _targetViewOriginFrame.origin.x - (width - _targetViewOriginFrame.size.width) / 2.0;

        self.headerViewTopConstraint.constant = 0;
        self.headerViewHeightConstraint.constant = heigth;
        self.headerViewLeadingConstraint.constant = self.headerViewTailingConstraint.constant = x;

        THScrollView *thScrollView = [self.headerView.subviews firstObject];
        [thScrollView setImageFrame:CGRectMake(x, 0, width, heigth)];

        self.headerView.userInteractionEnabled = NO;
    }

    float alpha = 1-offsetY/64.0;

    self.navigationBar.alpha = 1-alpha;
    self.titleView.alpha = fabs(1-(alpha*2));
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    THScrollView *thScrollView = [self.headerView.subviews firstObject];
    [thScrollView.animationTimer resumeTimerAfterTimeInterval:thScrollView.animationDuration];
}

#pragma mark - Event Response

- (IBAction)onCollectionButton:(id)sender
{
    self.isWish = !self.isWish;
}

#pragma mark - private methods

- (void)configViews
{
    self.focusButton.layer.borderColor = [Utils HexColorToRedGreenBlue:@"#F99D46"].CGColor;
    self.focusButton.layer.borderWidth = 1.0;
    self.focusButton.layer.cornerRadius = 3.0;

    self.avatarView.layer.cornerRadius = self.avatarView.bounds.size.height / 2.0;

    self.webView.scrollView.scrollEnabled = NO;

    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:[Utils HexColorToRedGreenBlue:@"#ededed"]];
}

- (void)setupActionBinds
{
    @weakify(self);
    [RACObserve(self.navigationBar, alpha)
     subscribeNext:^(NSNumber *x) {

         @strongify(self);

         if (x.floatValue < 0.5f)
         {
             [self.praiseButton setImage:[UIImage imageNamed:@"activity_unfavourite_normal"] forState:UIControlStateNormal];
             [self.shareButton setImage:[UIImage imageNamed:@"activity_share_narmal"] forState:UIControlStateNormal];
             [self.reportButton setImage:[UIImage imageNamed:@"report_normal"] forState:UIControlStateNormal];
             [self.backButton setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
         }
         else
         {
             [self.praiseButton setImage:[UIImage imageNamed:@"activity_unfavourite"] forState:UIControlStateNormal];
             [self.reportButton setImage:[UIImage imageNamed:@"report"] forState:UIControlStateNormal];
             [self.shareButton setImage:[UIImage imageNamed:@"activity_share"] forState:UIControlStateNormal];
             [self.backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
         }
     }];

    [[[RACObserve(self, isWish)
       deliverOnMainThread]
       filter:^BOOL(id value) {

           return value != nil;
       }]
       subscribeNext:^(NSNumber *x) {

           @strongify(self);

           self.collectionImageView.image = [UIImage imageNamed:x.boolValue ? @"activity_collection_select": @"activity_collection"];
           self.collectionText.text = x.boolValue ? @"取消收藏": @"收藏";
       }];

    [[RACObserve(self, join)
      filter:^BOOL(id value) {

        return value != nil;
      }]
      subscribeNext:^(NSArray *join) {

          @strongify(self);

          for (__strong UIView *view in self.joinBackgroundView.subviews)
          {
              [view removeFromSuperview];
              view = nil;
          }

          CGFloat padding = (kScreenWidth - 30 - 45*6) / 5;

          UIView *lastView = nil;
          NSInteger count = [join count] > 5 ? 5 : join.count;

          for (NSInteger index = 0; index < count; index ++)
          {
              NSString *URLString = join[index];

              UIImageView *imageView = [UIImageView new];
              imageView.layer.cornerRadius = 45.0 / 2;
              imageView.clipsToBounds = YES;
              imageView.userInteractionEnabled = YES;
              [imageView sd_setImageWithURL:[NSURL URLWithString:URLString]
                           placeholderImage:[UIImage imageNamed:@"avatar_default_big"]];

              [self.joinBackgroundView addSubview:imageView];

              [imageView mas_makeConstraints:^(MASConstraintMaker *make) {

                  make.height.and.width.equalTo(@45);
                  make.centerY.equalTo(self.joinBackgroundView);

                  if (lastView)
                  {
                      make.left.equalTo(lastView.mas_right).with.offset(padding);
                  }
                  else
                  {
                      make.left.equalTo(self.joinBackgroundView.mas_left).with.offset(15);
                  }
              }];

              lastView = imageView;
          }

          UILabel *countLabel = [UILabel new];
          countLabel.backgroundColor = [Utils HexColorToRedGreenBlue:@"#bdc0b9"];
          countLabel.textColor = [UIColor whiteColor];
          countLabel.font = [UIFont systemFontOfSize:15.0];
          countLabel.textAlignment = NSTextAlignmentCenter;
          countLabel.layer.cornerRadius = 45.0 / 2;
          countLabel.clipsToBounds = YES;
          countLabel.text = [NSString stringWithFormat:@"%zi+", join.count];

          [self.joinBackgroundView addSubview:countLabel];

          [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {

              make.width.and.height.equalTo(@45);
              make.centerY.equalTo(self.joinBackgroundView);

              if (lastView)
              {
                  make.left.equalTo(lastView.mas_right).with.offset(padding);
              }
              else
              {
                  make.left.equalTo(self.joinBackgroundView.mas_left).with.offset(15);
              }
          }];
      }];
}

@end
