//
//  ViewController.m
//  CMScrollview
//
//  Created by hky on 15/11/30.
//  Copyright © 2015年 hky. All rights reserved.
//

#import "ViewController.h"
#import "CMScrollview.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CMScrollview *scrollview = [[CMScrollview alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200) images:@[@"image1.JPG",@"image2.JPG",@"image3.JPG",@"image4.JPG",@"image5.JPG"] andTime:4.0 andActionBlock:^(NSInteger currentIndex) {
        NSLog(@"---- view did load current index :%@",@(currentIndex));
    }];
    [scrollview setBackgroundColor:[UIColor yellowColor]];
    [self.view addSubview:scrollview];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
