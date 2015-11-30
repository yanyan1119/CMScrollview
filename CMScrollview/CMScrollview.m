
//
//  CMScrollview.m
//  CMScrollview
//
//  Created by hky on 15/11/30.
//  Copyright © 2015年 hky. All rights reserved.
//

#define kWidth self.frame.size.width
#define kHeitht self.frame.size.height

#import "CMScrollview.h"

@interface CMScrollview()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) NSUInteger kImageCount;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger currentImageIndex;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) UIImageView *leftImageview;
@property (nonatomic, strong) UIImageView *currentImageview;
@property (nonatomic, strong) UIImageView *rightImageview;
@property (nonatomic, assign) BOOL isNeedUpdateImge;
@property (nonatomic, strong) void (^block)(NSInteger currentIndex);
@property (nonatomic, assign) CGFloat changeTime;

@end

@implementation CMScrollview

- (instancetype)initWithFrame:(CGRect)frame
                       images:(NSArray *)images
                      andTime:(CGFloat)changeTime
               andActionBlock:(void(^)(NSInteger currentIndex))block
{
    if (self = [super initWithFrame:frame]) {
        if (images.count < 1) {
            return nil;
        }
        _kImageCount = images.count;
        _imageArray = images;
        _changeTime = changeTime;
        _block = block;
        
        [self addSubImageviews];
    }
    return self;
}

- (void)addSubImageviews
{
    _leftImageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeitht)];
    [_leftImageview setImage:[UIImage imageNamed:_imageArray[0]]];
    [self.scrollview addSubview:_leftImageview];
    
    _currentImageview = [[UIImageView alloc] initWithFrame:CGRectMake(kWidth, 0, kWidth, kHeitht)];
    [_currentImageview setImage:[UIImage imageNamed:_imageArray[1]]];
    [self.scrollview addSubview:_currentImageview];
    _currentImageview.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCurrentImageView:)];
    [_currentImageview addGestureRecognizer:tap];
    
    _rightImageview = [[UIImageView alloc] initWithFrame:CGRectMake(kWidth  * 2, 0, kWidth, kHeitht)];
    [_rightImageview setImage:[UIImage imageNamed:_imageArray[2]]];
    [self.scrollview addSubview:_rightImageview];
    
    self.pageControl.currentPage = 0;
    _isNeedUpdateImge = NO;
    _timer = [NSTimer timerWithTimeInterval:_changeTime target:self selector:@selector(timerOut:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
}


- (void)timerOut:(NSTimer *)timer
{
    [_scrollview setContentOffset:CGPointMake(kWidth * 2, 0) animated:YES];
    _isNeedUpdateImge = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(scrollViewDidEndDecelerating:) userInfo:nil repeats:NO];
}

- (void)tapCurrentImageView:(UITapGestureRecognizer *)gesture
{
    _block(_currentImageIndex);
    NSLog(@"---- current index:%@",@(_currentImageIndex));
}

- (UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeitht)];
        [self addSubview:_scrollview];
        
        _scrollview.bounces = NO;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.pagingEnabled = YES;
        _scrollview.contentSize = CGSizeMake(kWidth * 3, kHeitht);
        _scrollview.delegate = self;
        
        [_scrollview setContentOffset:CGPointMake(kWidth, 0) animated:YES];
    }
    return _scrollview;
}


- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = _kImageCount;
        CGSize size = [_pageControl sizeForNumberOfPages:_kImageCount];
        _pageControl.bounds = CGRectMake(0, 0, size.width,size.height);
        _pageControl.center = CGPointMake(self.center.x, self.frame.size.height - size.height/2);
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        
        [self addSubview:_pageControl];
    }
    return _pageControl;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_scrollview.contentOffset.x == 0)
    {
        _currentImageIndex = (_currentImageIndex-1)%_kImageCount;
        _pageControl.currentPage = (_pageControl.currentPage - 1)%_kImageCount;
    }
    else if(_scrollview.contentOffset.x == kWidth * 2)
    {
        
        _currentImageIndex = (_currentImageIndex+1)%_imageArray.count;
        _pageControl.currentPage = (_pageControl.currentPage + 1)%_kImageCount;
    }
    else
    {
        return;
    }
    
    _leftImageview.image = [UIImage imageNamed:_imageArray[(_currentImageIndex-1)%_kImageCount]];
    
    
    _currentImageview.image = [UIImage imageNamed:_imageArray[_currentImageIndex%_kImageCount]];
    
    _rightImageview.image = [UIImage imageNamed:_imageArray[(_currentImageIndex+1)%_kImageCount]];
    
    
    _scrollview.contentOffset = CGPointMake(kWidth, 0);
    
    //手动控制图片滚动应该取消那个N秒的计时器
    if (!_isNeedUpdateImge)
    {
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_changeTime]];
    }
    _isNeedUpdateImge = NO;
}


@end
