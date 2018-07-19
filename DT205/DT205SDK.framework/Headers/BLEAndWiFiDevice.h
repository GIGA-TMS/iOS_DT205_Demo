//
//  BLEAndWiFiDevice.h
//  GIGATMSSDK
//
//  Created by Gianni on 2018/5/8.
//  Copyright © 2018年 Gianni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>



@interface BLEAndWiFiDevice : NSObject



-(NSString *)getSDKVersion:(NSString*)identifier Version:(NSString*)version;
+(instancetype)sharedInstance;
-(instancetype)init;
-(instancetype)initWithChannl:(BOOL) isWiFi;
-(int)readBLERSSI;
-(NSString*)getDeviceName;
-(NSString*)getBLEConnectState;
-(void)connectBLEDevice:(CBPeripheral *)peripheral Recieve:(CBUUID*)RecieveUUID Send:(CBUUID*)SendUUID;
-(void)disconnectBLEDevice;
-(void)startToScanBLEDevice;
-(void)stopScanningBLEDevice;

-(void)startToScanEthernetDevice;
-(void)connectEthernetDevice:(NSString*) host Port:(NSString*)port;
-(void)reConnectEthernetDevice;
-(void)disconnectEthernetDevice;
-(void)setIPAndPort:(NSString*) host Port:(NSString*)port;

-(NSMutableDictionary*) getAllBLEDevice;
-(NSMutableDictionary*) getAllEthernetDevice;
#pragma mark - Command List


-(void)markCMDtoSendbyData:(NSData*)cmd;
-(NSData*)charToNSData:(char)cData;

-(void)test;

@end
