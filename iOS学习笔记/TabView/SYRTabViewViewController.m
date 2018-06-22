//
//  SYRTabViewViewController.m
//  iOS学习笔记
//
//  Created by 单怡然 on 2018/6/22.
//  Copyright © 2018年 单怡然. All rights reserved.
//

#import "SYRTabViewViewController.h"
#import "SYRViewController.h"
#import "SYRH5WebViewController.h"

@interface SYRTabViewViewController ()

@end

@implementation SYRTabViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SYRH5WebViewController *h5View = [[SYRH5WebViewController alloc]init];
    SYRViewController *commView = [[SYRViewController alloc]init];
    [self setTabBarItem:h5View.tabBarItem];
    [h5View.tabBarItem initWithTitle:@"消息" image:[UIImage imageNamed:@"消息.png"] tag:1];
    [commView.tabBarItem initWithTitle:@"联系人" image:[UIImage imageNamed:@"联系人.png"] tag:1];
    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:h5View];
    UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:commView];
    self.viewControllers = @[nav1,nav2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
