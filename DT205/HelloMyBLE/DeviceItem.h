//
//  DeviceItem.h
//  HelloMyBLE
//
//  Created by wilson on 2017/7/5.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceItem : NSObject
@property (nonatomic,strong) NSString* deviecName;
@property (nonatomic,strong) NSString* deviecIP;
@property (nonatomic,strong) NSString* deviecPort;
@property (nonatomic,strong) NSDate* seenDate;
@end
