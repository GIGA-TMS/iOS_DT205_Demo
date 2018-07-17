//
//  BLE_Helper.m
//  
//
//  Created by wilson on 2017/5/15.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import "BLE_Helper.h"
#import "Header.h"
#import "PeripheralItem.h"
#import "HomePageViewController.h"
#import "GNTCommad.h"


#import <CommonCrypto/CommonCryptor.h>
#import "NSData+AES.h"
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
    if (peripheralDT205 != nil) {
        if (characteristicDT205 != nil) {
            [peripheralDT205 setNotifyValue:NO forCharacteristic:characteristicDT205];
            [manager cancelPeripheralConnection:peripheralDT205];
        }
    }
}

-(void)Glog:(NSString*) title data:(NSData *) cmdData {
    
    int nBuffLength = (int) [cmdData length];
    const char* pBuff =  (unsigned char*) [cmdData bytes];
    
    NSString* strDbgString = @"Glog ";
    strDbgString = [NSString stringWithFormat:@"( %d ) :", nBuffLength];
    for( int a=0 ; a<nBuffLength ; a++ ) {
        strDbgString = [NSString stringWithFormat:@"%@ 0x%02X", strDbgString, (pBuff[a]&0x0FF) ];
    }
    
    
    NSLog(@"%@ Gianni Glog :%@",title ,strDbgString);
    
}


-(void)writeValue:(NSData *)data{
    if (peripheralDT205 != nil && characteristicDT205 != nil) {
        NSLog(@"writeValue");
        [self Glog:@"writeValue" data:data];
        if (data.length > 20) {
            
            NSData* one = [data subdataWithRange:NSMakeRange(0, 20)];
            NSData* two = [data subdataWithRange:NSMakeRange(20, data.length-20)];
            [peripheralDT205 writeValue:one forCharacteristic:characteristicDT205 type:CBCharacteristicWriteWithResponse];
            sleep(0.5);
            [peripheralDT205 writeValue:two forCharacteristic:characteristicDT205 type:CBCharacteristicWriteWithResponse];
        }else{
            [peripheralDT205 writeValue:data forCharacteristic:characteristicDT205 type:CBCharacteristicWriteWithResponse];
        }
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
        NSLog(@"Discorver peripheral.identifier.UUIDString:%@",peripheral.identifier.UUIDString);
    }
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    
    
    PeripheralItem* newItem = [PeripheralItem new];
    newItem.peripheral = peripheral;
    newItem.localName = localName;
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
   // GNTCommad* gntCommand = [GNTCommad new];
   // [gntCommand handleCallbackData:callbackData];
    [self handleCallbackData:callbackData];
}
-(void)handleCallbackData:(NSData*) data{
    [self Glog:@"handleCallbackData" data:data];
    NSUInteger len = [data length];
    const unsigned char* pcBuffer = [data bytes];
    for (int i = 0 ; i<len; i++) {
        char data = pcBuffer[i];
        if (data == (char)DEVICE_COMMAND_HEAD) {
            _callBackDataBuffer = [NSMutableData new];
            isHeaderExist = true;
        }else if(data == (char)DEVICE_COMMAND_END){
            if (_callBackDataBuffer.length > 0) {
                
                NSString* callBackDataString = [[NSString alloc]initWithData:_callBackDataBuffer encoding:NSUTF8StringEncoding];
                
                if ([callBackDataString containsString:@"DT205"]) {
                    NSArray* separatedRandomString = [callBackDataString componentsSeparatedByString:@","];
                    if(sizeof(separatedRandomString) >= 3) {
                        NSString* randomString = separatedRandomString[2];
                        unsigned char aBuffer[100];
                        unsigned char* bBuffer =(unsigned char*)[randomString UTF8String];
                        int j=0;
                        for (int i = 0; i<16; i=i+2) {
                            unsigned char data1=bBuffer[i];
                            unsigned char data2=bBuffer[i+1];
                            printf(" %02X%02X ", data1, data2);
                            if(data1 >='0' && data1 <='9')
                            {
                                data1-='0';
                            }
                            else if(data1 >='A' && data1<='F')
                            {
                                data1=data1-'A';
                                data1=data1+0xA;
                            }
                            if(data2 >='0' && data2 <='9')
                            {
                                data2-='0';
                            }
                            else if(data2 >='A' && data2<='F')
                            {
                                data2=data2-'A';
                                data2=data2+0xA;
                            }
                            
                            aBuffer[j]=(data1<<4) | data2;
                            j++;
                        }
                        
                        aBuffer[8] = ~(aBuffer[0]) + (aBuffer[7]);
                        aBuffer[9] = ~(aBuffer[3]) ^ (aBuffer[4]);
                        aBuffer[10] = ~(aBuffer[5]) + (aBuffer[1]);
                        aBuffer[11] = ~(aBuffer[2]) ^ aBuffer[6];
                        aBuffer[12] = ~(aBuffer[8]) ^ aBuffer[9];
                        aBuffer[13] = ~(aBuffer[10]) + aBuffer[11];
                        aBuffer[14] = aBuffer[0] ^ aBuffer[1] + aBuffer[2] + aBuffer[3] + aBuffer[4] ^ aBuffer[5] + aBuffer[6] ^ aBuffer[7];
                        aBuffer[15] = aBuffer[8] + aBuffer[9] + aBuffer[10] + aBuffer[11] + aBuffer[12] + aBuffer[13] + aBuffer[14] + 0x57;
                        
                        printf("\n\n");
                        for(int i=0; i<16; i++)
                            printf("0x%02X ", aBuffer[i]);
                        printf("\n\n");
                        
                        //AES KEY
                        NSData* aes_Key = [[NSData alloc]initWithBytes:aBuffer length:16];
                        
                        
                        NSString* uuidString = [[UIDevice currentDevice].identifierForVendor UUIDString];
                        NSArray* separatedUUID = [uuidString componentsSeparatedByString:@"-"];
                        NSMutableData* mobileDevicePlaintext = [[NSMutableData alloc]init];
                        
                        NSString* uuidStringSub = [NSString stringWithFormat:@"%@%@%@",separatedUUID[0],separatedUUID[1],separatedUUID[2]];
                        NSData* test =[uuidStringSub dataUsingEncoding:NSUTF8StringEncoding];
                        
                        for (int i = 0; i<16; i+=2) {
                            unsigned result = 0;
                            NSScanner* scanner = [NSScanner scannerWithString:[uuidStringSub substringWithRange:NSMakeRange(i, 2)]];
                            [scanner setScanLocation:0];
                            [scanner scanHexInt:&result];
                            [mobileDevicePlaintext appendBytes:&result length:1];
                        }
                        
                        NSString* password = [[NSUserDefaults standardUserDefaults]objectForKey:PASSWORD];
                        NSLog(@"password:%@",password);
                        for (int i=0; i<12; i+=2) {
                            if (password.length > 2) {
//                                unsigned result = 0;
//                                NSScanner* scanner = [NSScanner scannerWithString:[password substringWithRange:NSMakeRange(i, 2)]];
//                                [scanner setScanLocation:0];
//                                [scanner scanHexInt:&result];
//                                [mobileDevicePlaintext appendBytes:&result length:1];
                            }
                            
                        }
                        
                        NSLog(@"crc16 %hu",[self crc16:mobileDevicePlaintext Len:14]);
                        
                        uint16_t aaa = [self crc16:mobileDevicePlaintext Len:14];
                        [mobileDevicePlaintext appendBytes:&aaa length:2];
                        NSLog(@"加密前plan:%@",mobileDevicePlaintext);
                        
                        {
                            size_t outLength;
                            NSMutableData* decryptedData = [NSMutableData dataWithLength:mobileDevicePlaintext.length + kCCBlockSizeAES128];
                            
                            CCCryptorStatus result = CCCrypt(kCCDecrypt,
                                                             kCCAlgorithmAES128,
                                                             kCCOptionPKCS7Padding,
                                                             aes_Key.bytes,
                                                             kCCKeySizeAES128,
                                                             nil,
                                                             mobileDevicePlaintext.bytes,
                                                             mobileDevicePlaintext.length,
                                                             decryptedData.mutableBytes,
                                                             decryptedData.length,
                                                             &outLength);
                            if (result == kCCSuccess) {
                                decryptedData.length = outLength;
                                NSLog(@"%@",decryptedData);
                                _callBackDataBuffer = decryptedData;
                            }
                        }
                        NSLog(@"%@",_callBackDataBuffer);
                    }
                    
                    
              }
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CallbackData" object:nil];
            }
            _callBackDataBuffer = [NSMutableData new];
            isHeaderExist = false;
        }else if(isHeaderExist){
            [_callBackDataBuffer appendBytes:&data length:1];
        }
    }
}
//-(void)handleCallbackData:(NSData*) data{
//    NSUInteger len = [data length];
//    const unsigned char* pcBuffer = [data bytes];
//    for (int i = 0 ; i<len; i++) {
//        char data = pcBuffer[i];
//        if (data == (char)DEVICE_COMMAND_HEAD) {
//            _callBackDataBuffer = [NSMutableData new];
//            isHeaderExist = true;
//        }else if(data == (char)DEVICE_COMMAND_END){
//            if (_callBackDataBuffer.length > 0) {
//                [[NSNotificationCenter defaultCenter]postNotificationName:@"CallbackData" object:nil];
//            }
//            _callBackDataBuffer = [NSMutableData new];
//            isHeaderExist = false;
//        }else if(isHeaderExist){
//            [_callBackDataBuffer appendBytes:&data length:1];
//        }
//    }
//}
-(uint16_t)crc16:(NSMutableData*)data Len:(int)len {
    const char *byte = (const char*)[data bytes];
    return gNETPlusCRC16Buffer(byte, len);
}
uint16_t gNETPlusCRC16Buffer(const char *buffer ,int iDataLen){
    const CRC_PRESET = 0xFFFF;
    const CRC_POLYNOM = 0xA001;
    unsigned short nCRC16 = CRC_PRESET;
    while (iDataLen--) {
        nCRC16 ^= *buffer;
        buffer++;
        for (int i=0; i<8; i++) {
            if ((nCRC16 & 1)==1) {
                nCRC16 = (nCRC16>>1)^CRC_POLYNOM;
            }else{
                nCRC16 = (nCRC16>>1);
            }
        }
    }
    return nCRC16;
}


@end
