//
//  ViewController.m
//  iOS学习笔记
//
//  Created by 单怡然 on 2018/6/14.
//  Copyright © 2018年 单怡然. All rights reserved.
//

#import "ViewController.h"
#import "SYRProtocol.h"

//当前类是委托类
@interface ViewController ()<SYRProtocol>
/**在.m文件里的interface中添加该类的私有属性,   .m文件的interface称为类扩展**/
@property(nonatomic,weak)UILabel *label;
@property(nonatomic,weak)id delegate;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self clickRedButton];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark 添加点击方法
-(void)clickRedButton{
    NSLog(@"%s",__func__);
}

-(void)showOtherViewMethods:(NSArray *)array :(NSString *)string{
    
}

@end
