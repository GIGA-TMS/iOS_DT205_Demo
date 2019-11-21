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
-(void)Login:(NSString*) pin;
-(void)Login:(NSString*) pin :(NSString*) continuationCode;
-(void)Binding:(NSString*) pin;
-(void)Unbinding;

-(void)Logout;
-(void)Polling;
#pragma mark - General Command

-(void)GetFirmwareVersion;
-(void)TriggerToOpenDrawer;
-(void)ResetTriggerCounter;
-(void)GetCashDrawerStatus;
-(void)GetUsageCounterInRawMode;
-(void)GetTriggerCounter;
-(void)SetSensorType:(bool)isNormal;
-(void)SetAlarm:(bool)isEnable;

-(void)GetSensorType;
-(void)GetAlarm;

-(BOOL)setRemindTimeout:(int) second;
-(void)getRemindTimeout;


-(void)UpdateSettingChanges;

-(void)GetDeviceName;
-(void)SetDeviceName:(NSString*)devName;
-(void)GetContinuationCode;

@end
