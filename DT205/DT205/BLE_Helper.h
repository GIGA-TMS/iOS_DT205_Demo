//
//  BLE_Helper.h
//  
//
//  Created by wilson on 2017/5/15.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface BLE_Helper : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic,strong) NSMutableDictionary* allPeripheralItems;
@property (nonatomic,strong) NSMutableData* callBackDataBuffer;
+(instancetype)sharedInstance;
-(void) startToScan;
-(void) stopScanning;
-(void) connectPeripheral:(CBPeripheral *)peripheral;
-(void) cancelPeripheral;
-(void) writeValue:(NSData*)data;
-(int) readRSSI;
@end
