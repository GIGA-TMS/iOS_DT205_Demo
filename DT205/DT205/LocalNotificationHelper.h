//
//  LocalNotificationHelper.h
//  
//
//  Created by wilson on 2017/5/12.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
@interface LocalNotificationHelper : NSObject

+(void)registeredLocalNotification;

-(void)pushLocalNotificationMessageTitle:(NSString*) title Body:(NSString*) body;

@end
