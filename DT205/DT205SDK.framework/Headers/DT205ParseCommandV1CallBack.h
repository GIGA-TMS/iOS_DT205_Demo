//
//  DT205ParseCommandV1CallBack.h
//  GIGATMSSDK
//
//  Created by Gianni on 2018/4/17.
//  Copyright © 2018年 Gianni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@protocol DT205ParseCommandV1CallBack <NSObject>

@optional

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;


@end
