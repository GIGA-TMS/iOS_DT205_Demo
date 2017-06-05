//
//  BLE_Helper.m
//  HelloMyBLE
//
//  Created by wilson on 2017/5/15.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import "BLE_Helper.h"
#import "Header.h"
#import "PeripheralItem.h"
#import "HomePageViewController.h"
@implementation BLE_Helper

{
    CBCentralManager* manager;
    CBPeripheral* peripheralDT205;
    CBCharacteristic* characteristicDT205;
    BOOL isHeaderExist;
    NSMutableDictionary* allItems;
    int peripheralRSSI;
    float rssi;
    int sumReadRSSI;
    int sumTarget;
}
static BLE_Helper* _singletonBLE_Helper = nil;
+(instancetype)sharedInstance{
    if (_singletonBLE_Helper == nil) {
        _singletonBLE_Helper = [[BLE_Helper alloc]init];
    }
    return _singletonBLE_Helper;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        // queue設定nil 會在main queue
        manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
    return self;
}
-(void) startToScan{
    // 指定掃描特定service
    if ([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_ISCONNECT]) {
        NSUUID* uuidBM100 = [[NSUUID UUID]initWithUUIDString:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY]];
        NSArray* peripheralArray = [manager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:uuidBM100]];
        if (peripheralArray.count>0) {
            peripheralDT205 = [peripheralArray objectAtIndex:0];
            NSLog(@"%@",peripheralDT205);
            [manager connectPeripheral:peripheralDT205 options:nil];
        }else{
            NSLog(@"Fail Arrary Nothing");
        }
    }else{
        CBUUID* uuid = [CBUUID UUIDWithString:TARGET_UUID_PREFIX];
        NSArray* services = @[uuid]; //@[uuid];
        //是否允許重複
        NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(true)};
        //帶空陣列 或 nil 可以做無差別掃描
        [manager scanForPeripheralsWithServices:services options:options];
    }
}
-(void) stopScanning{
    [manager stopScan];
}
-(void)connectPeripheral:(CBPeripheral *)peripheral{
    [manager connectPeripheral:peripheral options:nil];
}
-(void)cancelPeripheral{
    [peripheralDT205 setNotifyValue:NO forCharacteristic:characteristicDT205];
    [manager cancelPeripheralConnection:peripheralDT205];
}
-(void)writeValue:(NSData *)data{
    if (peripheralDT205 != nil && characteristicDT205 != nil) {
        [peripheralDT205 writeValue:data forCharacteristic:characteristicDT205 type:CBCharacteristicWriteWithResponse];
    }
}
-(int)readRSSI{
    [peripheralDT205 readRSSI];
    return peripheralRSSI;
}
#pragma mark - CBCentralManagerDelegate Methods
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    CBManagerState state = central.state;
    if (state != CBManagerStatePoweredOn) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"BLE_PowerOff" object:nil];
    }else{
        if ([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_ISCONNECT]) {
            [self startToScan];
        }
    }
}
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _allPeripheralItems = [NSMutableDictionary new];
    });
    PeripheralItem* existItem = _allPeripheralItems[peripheral.identifier.UUIDString];
    if (existItem == nil) {
        NSLog(@"Discorver %@,RSSI: %ld,UUID: %@\n,AdvData: %@",peripheral.name,(long)RSSI.integerValue,peripheral.identifier.UUIDString,advertisementData.description);
    }
    
    PeripheralItem* newItem = [PeripheralItem new];
    newItem.peripheral = peripheral;
    newItem.rssi = RSSI.integerValue;
    newItem.seenDate = [NSDate date];
    
    [_allPeripheralItems setObject:newItem forKey:peripheral.identifier.UUIDString];
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DiscorverPeripheral" object:nil];
    
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //連上設備後 先把掃描停止
    
    [[NSUserDefaults standardUserDefaults] setObject: peripheral.identifier.UUIDString forKey:DEVICE_UUID_KEY];
    [[NSUserDefaults standardUserDefaults] setBool: true forKey:DEVICE_ISCONNECT];
    
    NSLog(@"Peripheral connected: %@",peripheral.name);
    peripheralDT205 = peripheral;
    [self stopScanning];
    
    //Start to discover services
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:UUID_COMMUNICATE_SERVICE]]];
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:DEVICE_ISCONNECT]) {
        [self startToScan];
    }
}
#pragma mark - CBPeripheralDelegate Methods
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@"didDiscoverServices fail: %@",error);
        [manager cancelPeripheralConnection:peripheral];
        return;
    }
    for (CBService* service in peripheral.services) {
        //NSLog(@"service.UUID = ------ = %@",service.UUID.UUIDString);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:UUID_COMMUNICATE_SERVICE]]) {
            [service.peripheral discoverCharacteristics:nil forService:service];
            NSLog(@"開始尋找");
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"didDiscoverServices fail: %@",error);
        [manager cancelPeripheralConnection:peripheral];
        return;
    }
    //Prepare for characteristics part
    for (CBCharacteristic* tmp in service.characteristics) {
        NSLog(@"%@",tmp.UUID);
        //Check if it is the one that is matched With target UUID
        if ([tmp.UUID isEqual:[CBUUID UUIDWithString:UUID_COMMUNICATE_RECIEVE_CHARACTERISTIC]]) {
            peripheralDT205 = peripheral;
            [peripheralDT205 setNotifyValue:true forCharacteristic:tmp];
        }else if([tmp.UUID isEqual:[CBUUID UUIDWithString:UUID_COMMUNICATE_SEND_CHARACTERISTIC]]){
            characteristicDT205 = tmp;
        }
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"NotifyCharacteristic" object:nil];
}
-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    sumReadRSSI+=[RSSI intValue];
    sumTarget++;
    peripheralRSSI = sumReadRSSI/sumTarget;
    NSLog(@"%d",peripheralRSSI);
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSData* callbackData = characteristic.value;
    NSLog(@"%@",callbackData);
    [self handleCallbackData:callbackData];
}

-(void)handleCallbackData:(NSData*) data{
    NSUInteger len = [data length];
    const unsigned char* pcBuffer = [data bytes];
    for (int i = 0 ; i<len; i++) {
        char data = pcBuffer[i];
        if (data == (char)DEVICE_COMMAND_HEAD) {
            _callBackDataBuffer = [NSMutableData new];
            isHeaderExist = true;
        }else if(data == (char)DEVICE_COMMAND_END){
            if (_callBackDataBuffer.length > 0) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CallbackData" object:nil];
            }
            _callBackDataBuffer = [NSMutableData new];
            isHeaderExist = false;
        }else if(isHeaderExist){
            [_callBackDataBuffer appendBytes:&data length:1];
        }
    }
}
@end
