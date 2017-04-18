//
//  PeripheralItem.h
//  HelloMyBLE
//
//  Created by 陳維成 on 2017/2/9.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface PeripheralItem : NSObject

@property (nonatomic,strong) CBPeripheral* peripheral;
@property (nonatomic,strong) NSDate* seenDate;
//不是物件 所以用assign
@property (nonatomic,assign) NSInteger rssi;

@end
