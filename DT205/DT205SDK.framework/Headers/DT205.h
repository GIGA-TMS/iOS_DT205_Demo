//
//  DT205.h
//  TS800_SDK
//
//  Created by Gianni on 2018/2/9.
//  Copyright © 2018年 Gianni. All rights reserved.
//

#import "DT205CommandV1CallBack.h"
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DT205ParseCommandV1CallBack.h"
#import "BLEAndWiFiDevice.h"

@interface DT205 : BLEAndWiFiDevice

@property (nonatomic, assign) id<DT205CommandV1CallBack> dt205Listener;

+(instancetype)sharedInstance:(BOOL)isWiFi;
-(instancetype)init:(BOOL)isWiFi;
-(void)setDt205Listener:(id<DT205CommandV1CallBack>)listener;

-(NSString *)getSDKVersion;
-(void)connectBLEDevice:(CBPeripheral *)peripheral;


-(NSMutableDictionary*) getAllBLEDevice;

#pragma mark - Authenticate Command
-(void)cmdLogin:(NSString*) passward;
-(void)cmdSetPassword:(NSString*) newPassward;
-(void)cmdLogout;
-(void)cmdPolling;
#pragma mark - General Command

-(void)cmdGetFWVersion;
-(void)cmdCtrlTriggerToOpen;
-(void)cmdCtrlResetTriggerCounter;
-(void)cmdGetCashDrawerStatus;
-(void)cmdGetUsageCounterInRawMode;
-(void)cmdGetUsageCounter;
-(void)cmdSetSensorType:(bool)isNormal;
-(void)cmdSetSensorEnable:(bool)isEnable;

-(void)cmdGetSensorType;
-(void)cmdGetSensorEnable;


-(void)cmdUpdateSettingChanges;

@end
