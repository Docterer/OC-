//
//  SYRProtocol.h
//  iOS学习笔记
//
//  Created by 单怡然 on 2018/6/15.
//  Copyright © 2018年 单怡然. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SYRProtocol<NSObject>

@optional
-(void)showOtherViewMethods:(NSArray*) array :(NSString*) string;
@optional
-(void)sendMessageToOtherView:(NSDictionary*) dict;

@end

/*
 *代理中的注解
 *   required是必须要实现的。如果在创建协议前没有进行声明，那么默认是required
 *   optional是可选实现
 *   无论是required还是optional都是在约定代理是否强制遵循此协议
 */
