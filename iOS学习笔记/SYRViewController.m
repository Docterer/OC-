//
//  SYRViewController.m
//  iOS学习笔记
//
//  Created by 单怡然 on 2018/6/21.
//  Copyright © 2018年 单怡然. All rights reserved.
//

#import "SYRViewController.h"
@interface SYRViewController ()


@end

@implementation SYRViewController

- (void)viewDidLoad {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [super viewDidLoad];
}

- (void)putLabel{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 80, 300, 20)];
    label.text = [NSString stringWithFormat:@"请把头部放置在圆框中"];
    label.font = [UIFont boldSystemFontOfSize:22.0f];
    [self.view addSubview:label];
    //[self.view bringSubviewToFront:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
