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
-(void)didUpdateBLECentralManagerState:(NSString*) State;
-(void)didCMD_General_Success:(NSString*) CMDName;
-(void)didCMD_General_ERROR:(NSString*) CMDName errMassage:(NSString*) errMassage;
-(void)didCMD_Polling:(NSString*) ProductName LoginState:(NSString*)LoginState Random:(NSData*) Random;
-(void)didCMD_FW_Ver:(NSString*)fwName fwVer:(NSString*)fwVer;
-(void)didCMD_GetCashDrawerStatus:(bool) isOpen;
//-(void)didCMD_GetUsageCounterInRawMode(String Usage);
-(void)didCMD_GetUsageCounter:(NSString*) Count;


-(void)didCMD_GetSensorType:(bool) isNormal;
-(void)didCMD_GetSensorEnable:(bool) isEnable;


-(void)didCMD_GetDeviceName:(NSString*) devName;

-(void)didCreateContinuationCode:(NSString*) code;

//Event
-(void)didEvent_StatusChanged:(bool) isOpen;
-(void)didEvent_OpenAlert:(bool) isOpen;
-(void)didEvent_OpenReminding:(bool) isOpen;





@end
