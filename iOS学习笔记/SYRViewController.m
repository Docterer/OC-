//
//  SYRViewController.m
//  iOS学习笔记
//
//  Created by 单怡然 on 2018/6/21.
//  Copyright © 2018年 单怡然. All rights reserved.
//

#import "SYRViewController.h"
@interface SYRViewController ()<UITableViewDataSource>
@property (weak, nonatomic) UITableView *tableView;

@end

@implementation SYRViewController

- (void)viewDidLoad {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self tableView];
    [super viewDidLoad];
}

- (UITableView *)tableView
{
    if(_tableView == nil){
        _tableView = ({
            UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            [self.view addSubview:tableView];
            tableView;
        });
    }
    return _tableView;
}

- (void)putLabel{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 80, 300, 20)];
    label.text = [NSString stringWithFormat:@"请把头部放置在圆框中"];
    label.font = [UIFont boldSystemFontOfSize:22.0f];
    [self.view addSubview:label];
    //[self.view bringSubviewToFront:label];
}


- (void)didAddButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"确定" forState:<#(UIControlState)#>];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//一共有几组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView");
    return 2;
}

//每组几行数据
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

//每行显示什么样的数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //indexPath.section     第几组
    //indexPath.row         第几行
    UITableViewCell *tableCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if(indexPath.section == 0){//第0组
        if(indexPath.row == 0){//第0组第0行
            tableCell.textLabel.text = @"爹";
        }else if(indexPath.row == 1){//第0组第一行
            tableCell.textLabel.text = @"妈";
        }
    }else if(indexPath.section == 1){
        if(indexPath.row == 0){//第一组第0行
            tableCell.textLabel.text = @"爷爷";
        }else if(indexPath.row == 1){//第一组第1行
            tableCell.textLabel.text = @"奶奶";
        }
    }
    return tableCell;
}

//第section组头部显示的标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return @"父母";
    }else{
        return @"爷奶";
    }
}

//第section组底部显示的标题
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 0){
        return @"物理";
    }else{
        return @"化学";
    }
}

//编辑状态，点击删除时调用
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyleforRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//设定横向滑动时是否出现删除按扭,（阻止第一行出现）
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return UITableViewCellEditingStyleNone;
    }
    
    else{
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleDelete;
}

@end
