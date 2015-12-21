
//
//  CMScrollview.m
//  CMScrollview
//
//  Created by hky on 15/11/30.
//  Copyright © 2015年 hky. All rights reserved.
//

#define kHeight self.frame.size.height

#import "CMScrollview.h"

@interface CMScrollview()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger currentImageIndex;
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
        _imageArray = images;
        _changeTime = changeTime;
        _block = block;
        
        [self addSubImageviews];
    }
    return self;
}

- (void)addSubImageviews
{
    _leftImageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kHeight)];
    [_leftImageview setContentMode:UIViewContentModeScaleAspectFill];
    [_leftImageview setClipsToBounds:YES];
    [self.scrollview addSubview:_leftImageview];
    
    _currentImageview = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, kHeight)];
    [self.scrollview addSubview:_currentImageview];
    _currentImageview.clipsToBounds = YES;
    [_currentImageview setContentMode:UIViewContentModeScaleAspectFill];
    _currentImageview.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCurrentImageView:)];
    [_currentImageview addGestureRecognizer:tap];
    
    _rightImageview = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width  * 2, 0, [UIScreen mainScreen].bounds.size.width, kHeight)];
    _rightImageview.clipsToBounds = YES;
    [_rightImageview setContentMode:UIViewContentModeScaleAspectFill];
    [self.scrollview addSubview:_rightImageview];
    
    NSInteger letfIndex = [self getIndexBycurrentIndex:_currentImageIndex -1];
    NSInteger rightIndex = [self getIndexBycurrentIndex:_currentImageIndex + 1];
    [_leftImageview setImage:[UIImage imageNamed:_imageArray[letfIndex]]];
    [_currentImageview setImage:[UIImage imageNamed:_imageArray[_currentImageIndex]]];
    [_rightImageview setImage:[UIImage imageNamed:_imageArray[rightIndex]]];
    [self restartTimer];
    self.pageControl.currentPage = _currentImageIndex;
}

- (void)dealloc
{
    [_timer invalidate];
}

-(void)upDateImageArray:(NSArray *)imageArray isTimerRun:(BOOL)isrun
{
    if (imageArray.count == 0)
    {
        return;
    }
    _imageArray = imageArray;
    if (_pageControl.superview)
    {
        [_pageControl removeFromSuperview];
    }
    
    [_timer invalidate];
    _timer = nil;
    _pageControl = nil;
    _currentImageIndex = 0;
    self.pageControl.currentPage = _currentImageIndex;
    
    NSInteger letfIndex = [self getIndexBycurrentIndex:_currentImageIndex -1];
    NSInteger rightIndex = [self getIndexBycurrentIndex:_currentImageIndex + 1];
    
    if (_imageArray.count > 1 && isrun)//设置默认图片
    {
        [self restartTimer];
    }
    if (_imageArray.count == 1)
    {
        _pageControl.hidden = YES;
        _scrollview.scrollEnabled = NO;
    }
    else
    {
        _pageControl.hidden = NO;
        _scrollview.scrollEnabled = YES;
    }
    [_leftImageview setImage:[UIImage imageNamed:_imageArray[letfIndex]]];
    [_currentImageview setImage:[UIImage imageNamed:_imageArray[_currentImageIndex]]];
    [_rightImageview setImage:[UIImage imageNamed:_imageArray[rightIndex]]];
    //    [_leftImageview sd_setImageWithURL:[NSURL URLWithString:_imageArray[letfIndex]] placeholderImage:@""];
    //    [_currentImageview sd_setImageWithURL:[NSURL URLWithString:_imageArray[0]] placeholderImage:@""];
    //    [_rightImageview sd_setImageWithURL:[NSURL URLWithString:_imageArray[rightIndex]] placeholderImage:@""];
}

- (void)restartTimer
{
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer timerWithTimeInterval:_changeTime target:self selector:@selector(timerOut:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)timerOut:(NSTimer *)timer
{
    [_scrollview setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width * 2, 0) animated:YES];
    _isNeedUpdateImge = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(scrollViewDidEndDecelerating:) userInfo:nil repeats:NO];
}

- (void)tapCurrentImageView:(UITapGestureRecognizer *)gesture
{
    _block(_currentImageIndex);
}

- (UIScrollView *)scrollview
{
    if (!_scrollview)
    {
        _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kHeight)];
        [self addSubview:_scrollview];
        
        _scrollview.bounces = NO;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.pagingEnabled = YES;
        _scrollview.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 3, kHeight);
        _scrollview.delegate = self;
        
        [_scrollview setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0) animated:YES];
    }
    return _scrollview;
}

-(NSInteger)getIndexBycurrentIndex:(NSInteger)index
{
    NSInteger retIndex;
    if (index == -1) {
        retIndex = _imageArray.count - 1;
    }
    else if(index == _imageArray.count)
    {
        retIndex = 0;
    }
    else
    {
        retIndex = index;
    }
    return retIndex;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl)
    {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = _imageArray.count;
        CGSize size = [_pageControl sizeForNumberOfPages:_imageArray.count];
        _pageControl.bounds = CGRectMake(0, 0, size.width,size.height);
        _pageControl.center = CGPointMake([UIScreen mainScreen].bounds.size.width - 30 - size.width/2, kHeight - size.height/2);
        [_pageControl setBackgroundColor:[UIColor clearColor]];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        [self addSubview:_pageControl];
    }
    return _pageControl;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (_imageArray.count == 0) {
        return;
    }
    NSString *string = _imageArray[0];
    if ([string isEqualToString:@"cmhome_meifabanner_default"] || [string isEqualToString:@"placeholderImage"])
    {
        return;
    }
    if (_scrollview.contentOffset.x == 0)
    {
        _currentImageIndex = [self getIndexBycurrentIndex:_currentImageIndex - 1];
    }
    else if(_scrollview.contentOffset.x == [UIScreen mainScreen].bounds.size.width * 2)
    {
        
        _currentImageIndex = [self getIndexBycurrentIndex:_currentImageIndex + 1];
        
    }
    else
    {
        return;
    }
    
    [_pageControl setCurrentPage:_currentImageIndex];
    
    NSInteger letfIndex = [self getIndexBycurrentIndex:_currentImageIndex -1];
    NSInteger rightIndex = [self getIndexBycurrentIndex:_currentImageIndex + 1];
    [_leftImageview setImage:[UIImage imageNamed:_imageArray[letfIndex]]];
    [_currentImageview setImage:[UIImage imageNamed:_imageArray[_currentImageIndex]]];
    [_rightImageview setImage:[UIImage imageNamed:_imageArray[rightIndex]]];
    //    [_leftImageview sd_setImageWithURL:[NSURL URLWithString:_imageArray[letfIndex]] placeholderImage:@""];
    //    [_currentImageview sd_setImageWithURL:[NSURL URLWithString:_imageArray[_currentImageIndex]] placeholderImage:@""];
    //    [_rightImageview sd_setImageWithURL:[NSURL URLWithString:_imageArray[rightIndex]] placeholderImage:@""];
    
    _scrollview.contentOffset = CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
    
    //手动控制图片滚动应该取消那个N秒的计时器
    if (!_isNeedUpdateImge)
    {
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_changeTime]];
    }
    _isNeedUpdateImge = NO;
}

@end
