//
//  ViewController.h
//  iOS学习笔记
//
//  Created by 单怡然 on 2018/6/14.
//  Copyright © 2018年 单怡然. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

/***在.h文件中添加的属性为暴露的公有属性，这样就是在其他的类中只需要实例化了ViewController对象，就能改变暴露的类属性的值,在Controller之间传值可以使用这种方法***/
@property(nonatomic,weak)UIImage *image;

@end

