//
//  LocalNotificationHelper.m
//  HelloMyBLE
//
//  Created by wilson on 2017/5/12.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import "LocalNotificationHelper.h"

@implementation LocalNotificationHelper

+(void)registeredLocalNotification{
    
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            NSLog(@"使用者不同意");
        }
    }];
}

-(void)pushLocalNotificationMessageTitle:(NSString *)title Body:(NSString *)body{
   
    UNMutableNotificationContent* content = [UNMutableNotificationContent new];
    content.title = title;
    content.body = body;
    content.sound = [UNNotificationSound defaultSound];
    
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:false];
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"notification1" content:content trigger:trigger];
    [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:nil];
}

@end
