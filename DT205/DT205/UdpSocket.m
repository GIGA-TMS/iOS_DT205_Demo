//
//  UdpSocket.m
//  GigatmsWifi
//
//  Created by wilson on 2017/6/9.
//  Copyright © 2017年 wilson. All rights reserved.
//

#import "UdpSocket.h"
#import "DeviceItem.h"
@implementation UdpSocket
{
    GCDAsyncUdpSocket* udpSocket;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        udpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *error = nil;
        uint16_t port = 0;
        
        if(![udpSocket bindToPort :port error:&error])
        {
            NSLog(@"error in bindToPort");
            //return;
        }else{
            [udpSocket beginReceiving:&error];
            [self enableBroadcast:YES];
        }
    }
    return self;
}
-(void)enableBroadcast:(BOOL) enable{
    [udpSocket enableBroadcast:enable error:nil];
}
-(void)sendData:(NSData *)data toHost:(NSString *)host port:(uint16_t)port withTimeout:(NSTimeInterval)timeout tag:(long)tag{
    
    [udpSocket sendData:data toHost:host port:port withTimeout:timeout tag:tag];
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    NSLog(@"連上去了");
    
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"送出去");
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"沒送出去:%@",error);
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    
    
    NSString* callback = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",callback);
    if ([callback containsString:@"A,"]) {
        NSArray* callbackArray = [callback componentsSeparatedByString:@","];
        NSLog(@"%@",callbackArray);
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _allDeviceItems = [NSMutableDictionary new];
        });
        
        DeviceItem* existItem = _allDeviceItems[callbackArray[1]];
        if (existItem == nil) {
            NSLog(@"找到新的Device");
        }
        DeviceItem* newItem = [DeviceItem new];
        newItem.deviecName = callbackArray[1];
        newItem.deviecIP = callbackArray[2];
        newItem.deviecPort = callbackArray[3];
        newItem.seenDate = [NSDate date];
        
        [_allDeviceItems setObject:newItem forKey:callbackArray[1]];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DiscoverDevice" object:nil];
    }
}
@end
