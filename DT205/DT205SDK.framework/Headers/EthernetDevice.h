//
//  EthernetDevice.h
//  GIGATMSSDK
//
//  Created by Gianni on 2018/5/7.
//  Copyright © 2018年 Gianni. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EthernetDevice : NSObject
@property (nonatomic,strong) NSString* deviecMacAddr;
@property (nonatomic,strong) NSString* deviecName;
@property (nonatomic,strong) NSString* deviecVersion;
@property (nonatomic,strong) NSString* deviecIP;
@property (nonatomic,strong) NSString* deviecPort;
@property (nonatomic,strong) NSDate* seenDate;
@end
