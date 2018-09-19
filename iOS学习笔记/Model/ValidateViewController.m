//
//  ValidateViewController.m
//  iOS学习笔记
//
//  Created by 单怡然 on 2018/9/9.
//  Copyright © 2018年 单怡然. All rights reserved.
//

#import "ValidateViewController.h"

@interface ValidateViewController ()<UITextFieldDelegate,UITextViewDelegate>

@end

@implementation ValidateViewController

//设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    NSLog(@"statusBar.backgroundColor--->%@",statusBar.backgroundColor);
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //设置导航条透明度
    self.navigationController.navigationBar.translucent = NO;//不透明
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
    //图标颜色为黑色
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    //导航栏背景颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    //导航条下面的黑线
    self.navigationController.navigationBar.clipsToBounds = NO;
    
    //刷新状态栏背景颜色
    // [self setNeedsStatusBarAppearanceUpdate];
    
    //设置状态栏颜色
    [self setStatusBarBackgroundColor:[UIColor blackColor]];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //为了不影响其他页面在viewDidDisappear做以下设置
    self.navigationController.navigationBar.translucent = YES;//透明
    [self setStatusBarBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
