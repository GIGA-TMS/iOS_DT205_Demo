//
//  Header.h
//  HelloMyBLE
//
//  Created by wilson on 2017/4/18.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#ifndef Header_h
#define Header_h

//Peripheral
#define RELOAD_TIME_INTERVAL 1.0
#define TARGET_UUID_PREFIX @"FEE7"
#define UUID_COMMUNICATE_SERVICE                @"0000fff0-0000-1000-8000-00805f9b34fb"
#define UUID_COMMUNICATE_RECIEVE_CHARACTERISTIC @"0000fff1-0000-1000-8000-00805f9b34fb"
#define UUID_COMMUNICATE_SEND_CHARACTERISTIC    @"0000fff2-0000-1000-8000-00805f9b34fb"
#define UUID_CLIENT_CONFIG_DESCRIPTOR           @"00002902-0000-1000-8000-00805f9b34fb"
// Device Command Set
#define DEVICE_COMMAND_HEAD                     0x02 //STX
#define DEVICE_COMMAND_END                      0x0D //CR
#define DEVICE_GET_NAME                         'D' //D
#define DEVICE_GET_VERSION                      'F' //F
#define DEVICE_CONTROL                          'K' //K
#define DEVICE_CONTROL_REST_ALARM               'A' //A
#define DEVICE_CONTROL_BEEPFOR_10_SECONDS       'B' //B
#define DEVICE_CONTROL_REDLED_BLINK_10_SECONDS  'R' //R
#define DEVICE_CONTROL_GREENLED_BLINK_10_SECONDS 'G'  //G
// Device Local Setting Key
#define DEVICE_UUID_KEY @"uuid"
#define DEVICE_ISCONNECT @"isConnect"
#define ROOTVIEWCONTROLLER @"HomePage"
#define PASSWORD @"password"

#endif /* Header_h */
