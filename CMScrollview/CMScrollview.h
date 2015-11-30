//
//  CMScrollview.h
//  CMScrollview
//
//  Created by hky on 15/11/30.
//  Copyright © 2015年 hky. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CMScrollview : UIView

- (instancetype)initWithFrame:(CGRect)frame
                       images:(NSArray *)images
                      andTime:(CGFloat)changeTime
               andActionBlock:(void(^)(NSInteger currentIndex))block;

@end
