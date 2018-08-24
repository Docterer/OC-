//
//  SYRWebView.m
//  iOS学习笔记
//
//  Created by 单怡然 on 2018/8/9.
//  Copyright © 2018年 单怡然. All rights reserved.
//

#import "SYRWebView.h"

@interface SYRWebView()

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation SYRWebView{
    NSString *htmlStr;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.webView];
    [self loadUrl:@"index"];
}


- (void)loadUrl:(NSString *)url
{
    //加载服务器url，实现代理方法。-----注意点拦截url解决webview加载本地连接不显示问题
    htmlStr = [[NSBundle mainBundle] pathForResource:url ofType:@"html"inDirectory:@"demo-tab-webview/"];
    NSLog(@"login登录:%@",htmlStr);
    NSURL* htmlUrl = [NSURL fileURLWithPath:htmlStr];
    NSURLRequest* request = [NSURLRequest requestWithURL:htmlUrl];
    [self.webView loadRequest:request];
    
}

#pragma mark -- 懒加载
- (UIWebView *)webView{
    //第一步：懒加载。
    if (!_webView) {
        _webView = ({
            self.edgesForExtendedLayout = UIRectEdgeNone;
            //controller中添加
            self.automaticallyAdjustsScrollViewInsets = NO;
            UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height+60)];
            webView.delegate = self;
            webView.dataDetectorTypes = UIDataDetectorTypeAll;
            webView.scalesPageToFit = YES;//自动对页面进行缩放以适应屏幕
            webView.scrollView.bounces = NO ;//禁止回弹方法
            webView;
        });
    }
    return _webView;
}

@end
