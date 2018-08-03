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
#import "SpeakToTxtViewController.h"

@interface SYRTabViewViewController ()
@property(nonatomic,strong) SYRH5WebViewController *syrH5View;
@property(nonatomic,strong) SYRViewController *syrView;
@property(nonatomic,strong) SpeakToTxtViewController *speakView;
@end

@implementation SYRTabViewViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:self.syrH5View];
    UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:self.syrView];
    UINavigationController *nav3 = [[UINavigationController alloc]initWithRootViewController:self.speakView];
    self.viewControllers = @[nav1,nav2,nav3];
}

#pragma tab set
-(SYRH5WebViewController *)syrH5View
{
    if(_syrH5View == nil){
        _syrH5View = [[SYRH5WebViewController alloc]init];
        [_syrH5View.tabBarItem setTitle:@"消息"];
        [_syrH5View.tabBarItem setImage:[UIImage imageNamed:@"消息"]];
    }
    return _syrH5View;
}

-(SYRViewController *)syrView
{
    if(_syrView == nil){
        _syrView = [[SYRViewController alloc]init];
        [_syrView.tabBarItem setTitle:@"联系人"];
        [_syrView.tabBarItem setImage:[UIImage imageNamed:@"联系人"]];
    }
    return _syrView;
}

-(SpeakToTxtViewController *)speakView
{
    if(_speakView == nil){
        _speakView = [[SpeakToTxtViewController alloc]init];
        [_speakView.tabBarItem setTitle:@"语音"];
        [_speakView.tabBarItem setImage:[UIImage imageNamed:@"动态"]];
    }
    return _speakView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
