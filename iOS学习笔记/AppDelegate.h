//
//  AppDelegate.h
//  iOS学习笔记
//
//  Created by 单怡然 on 2018/6/14.
//  Copyright © 2018年 单怡然. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

