//
//  UdpSocket.h
//  GigatmsWifi
//
//  Created by wilson on 2017/6/9.
//  Copyright © 2017年 wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncUdpSocket.h>
@interface UdpSocket : NSObject<GCDAsyncUdpSocketDelegate>
@property (nonatomic,strong) NSMutableDictionary* allDeviceItems;
-(void)sendData:(NSData *)data toHost:(NSString *)host port:(uint16_t)port withTimeout:(NSTimeInterval)timeout tag:(long)tag;
-(void)enableBroadcast:(BOOL) enable;
@end
