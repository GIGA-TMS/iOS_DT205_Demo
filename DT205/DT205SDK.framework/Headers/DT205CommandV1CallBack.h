//
//  DT205CommandV1CallBack.h
//  GIGATMSSDK
//
//  Created by Gianni on 2018/4/12.
//  Copyright © 2018年 Gianni. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@protocol DT205CommandV1CallBack <NSObject>

@optional
-(void)onDidUpdateBLECentralManagerState:(NSString*) State;

-(void)onDidGeneralSuccess:(NSString*) CMDName;
-(void)onDidGeneralError:(NSString*) CMDName errMassage:(NSString*) errMassage;
-(void)onDidPolling:(NSString*) ProductName LoginState:(NSString*)LoginState;
-(void)onDidGetFirmwareVersion:(NSString*)fwName fwVer:(NSString*)fwVer;
-(void)onDidGetCashDrawerStatus:(bool) isOpen;

-(void)onDidGetTriggerCounter:(NSString*) Count;


-(void)onDidGetSensorType:(bool) isNormal;
-(void)onDidGetAlarm:(bool) isEnable;


-(void)onDidGetDeviceName:(NSString*) devName;

-(void)onDidGetContinuationCode:(NSString*) code;

//Event
-(void)onEventStatusChanged:(bool) isOpen;
-(void)onEventOpenAlert:(bool) isOpen;
-(void)onEventOpenReminding:(bool) isOpen;

-(void)onDidGetBleRssi:(int) rssi;

-(void)onDidGetRemindTimeout:(int) second;

@end
