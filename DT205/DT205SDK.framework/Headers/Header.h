//
//  Header.h
//
//
//  Created by Gianni on 2017/4/18.
//  Copyright © 2017年 Gianni. All rights reserved.
//

#ifndef Header_h
#define Header_h

//Peripheral
#define RELOAD_TIME_INTERVAL                                1.0
#define TARGET_UUID_PREFIX                                  @"FFF0"
#define UUID_COMMUNICATE_SERVICE                            @"0000fff0-0000-1000-8000-00805f9b34fb"
#define DT205_UUID_COMMUNICATE_RECIEVE_CHARACTERISTIC       @"0000fff1-0000-1000-8000-00805f9b34fb"
#define DT205_UUID_COMMUNICATE_SEND_CHARACTERISTIC          @"0000fff2-0000-1000-8000-00805f9b34fb"
#define TS800_UUID_COMMUNICATE_RECIEVE_CHARACTERISTIC      @"0000fff3-0000-1000-8000-00805f9b34fb"
#define TS800_UUID_COMMUNICATE_SEND_CHARACTERISTIC         @"0000fff4-0000-1000-8000-00805f9b34fb"
#define UUID_CLIENT_CONFIG_DESCRIPTOR                       @"00002902-0000-1000-8000-00805f9b34fb"
// TS800 Device Command Set
#define TS800_DEVICE_COMMAND_HEAD                         0x01 //SOH


//Gianni
#define QueryFirmwareVersion                        0x10
#define SelectActiveMode                            0x12
#define SetSetting                                  0x22
#define GetSetting                                  0x24



#define ACTIVEMODE_DC                               0xDC
#define ACTIVEMODE_AUTO                             0x00 // Auto
#define ACTIVEMODE_COMMAND                          0x01 // Command
//#define DEVICE_GET_NAME                         'D'  //D
//#define DEVICE_GET_VERSION                      'F'  //F
//#define DEVICE_OPENCASHDRAWER                   'K' //K
//#define DEVICE_OPENCASHDRAWER_PARAMETER         'c' //c
//#define DEVICE_GET_STATUS                       'J' //J
//#define DEVICE_GET_STATUS_PARAMETER             'c' //c
// Device Local Setting Key
#define DEVICE_UUID_KEY @"uuid"
#define DEVICE_RecieveUUID_KEY @"RecieveUUID"
#define DEVICE_SendUUID_KEY @"SendUUID"
#define DEVICE_ISCONNECT @"isConnect"
#define ROOTVIEWCONTROLLER @"HomePage"
#define PASSWORD @"password"

#define  DT205_ReplyCMD_OK              0x41
#define  DT205_ReplyCMD_FAILED          0x4E
#define  DT205_DEVICE_COMMAND_HEAD                         0x02 //SOH
#define  DT205_DEVICE_COMMAND_END                          0x0D //CR
#define  DT205_LOGIN                    'L' //(0x4C)
#define  DT205_SETPASSWORD              'P' //(0x50)
#define  DT205_LOGOUT                   'O' //(0x4F)
#define  DT205_POLLING                  'D' //(0x44)
#define  DT205_GETFWVERSION             'F' //(0x46)
#define  DT205_CTRLDEVICE               'K' //(0x4B)

#define  DT205_CTRL_TRIGGERTOOPEN       'c' //(0x63)
#define  DT205_CTRL_RESETTRIGGERCOUNTER 'r' //(0x72)


#define  DT205_GETSTATUS                'J' //(0x4A)

#define  DT205_GET_CASHDRAWERSTATUS         'c' //(0x63)
#define  DT205_GET_USAGECOUNTERINRAWMODE    'r' //(0x72)
#define  DT205_GET_USAGECOUNTER             'a' //(0x61)



#define  DT205_SETSETTING               'C' //(0x43)
#define  DT205_GETSETTING               'B' //(0x42)
#define  DT205_UPDATESETTINGCHANGES     'R' //(0x52)


#define  DT205_EVENT                    '*' //(0x2A)
#define  DT205_EVENT_CASHDRAWERSTATUS   'c' //(0x63)
#define  DT205_EVENT_OPENALERT          'r' //(0x72)
#define  DT205_EVENT_OPENREMINDING      'a' //(0x61)



#endif /* Header_h */
