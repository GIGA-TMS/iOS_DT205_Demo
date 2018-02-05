//
//  Header.h
//  
//
//  Created by wilson on 2017/4/18.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#ifndef Header_h
#define Header_h

//Peripheral
#define RELOAD_TIME_INTERVAL 1.0
#define TARGET_UUID_PREFIX @"FFF0"
#define UUID_COMMUNICATE_SERVICE                @"0000fff0-0000-1000-8000-00805f9b34fb"
#define UUID_COMMUNICATE_RECIEVE_CHARACTERISTIC @"0000fff1-0000-1000-8000-00805f9b34fb"
#define UUID_COMMUNICATE_SEND_CHARACTERISTIC    @"0000fff2-0000-1000-8000-00805f9b34fb"
#define UUID_CLIENT_CONFIG_DESCRIPTOR           @"00002902-0000-1000-8000-00805f9b34fb"
// Device Command Set
#define DEVICE_COMMAND_HEAD                     0x02 //STX
#define DEVICE_COMMAND_END                      0x0D //CR
#define DEVICE_GET_NAME                         'D'  //D
#define DEVICE_GET_VERSION                      'F'  //F
#define DEVICE_OPENCASHDRAWER                   'K' //K
#define DEVICE_OPENCASHDRAWER_PARAMETER         'c' //c
#define DEVICE_GET_STATUS                       'J' //J
#define DEVICE_GET_STATUS_PARAMETER             'c' //c
// Device Local Setting Key
#define DEVICE_UUID_KEY @"uuid"
#define DEVICE_ISCONNECT @"isConnect"
#define ROOTVIEWCONTROLLER @"HomePage"
#define PASSWORD @"password"

#endif /* Header_h */
