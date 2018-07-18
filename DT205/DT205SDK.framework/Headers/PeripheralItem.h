//
//  PeripheralItem.h
//
//
//  Created by Gianni on 2017/2/9.
//  Copyright © 2017年 Gianni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface PeripheralItem : NSObject

@property (nonatomic,strong) CBPeripheral* peripheral;
@property (nonatomic,strong) NSString *localName;
@property (nonatomic,strong) NSDate* seenDate;
@property (nonatomic,assign) NSInteger rssi;

@end
