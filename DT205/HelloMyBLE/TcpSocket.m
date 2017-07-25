//
//  Socket.m
//  GigatmsWifi
//
//  Created by wilson on 2017/6/2.
//  Copyright © 2017年 wilson. All rights reserved.
//

#import "TcpSocket.h"


#import "GNTCommad.h"
@implementation TcpSocket
{
    GCDAsyncSocket* _socket;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}
-(void) writeData:(NSData*) data{
    [_socket writeData:data withTimeout:-1.0 tag:0];
    
}
-(void)connectToHost:(NSString*) host Port:(NSString*)port{
    NSString *socketHost = host;
    int socketPort = [port intValue];
    //创建一个socket对象
//    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //连接
    NSError *error = nil;
    [_socket connectToHost:socketHost onPort:socketPort error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"連接成功");
    [_socket readDataWithTimeout:-1 tag:0];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TCP_Connected" object:nil];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    if (err) {
        NSLog(@"連接失敗");
    }
}
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"發送成功");
}
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"%@",data);
    NSString* callbackData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",callbackData);
    
    GNTCommad* command = [GNTCommad new];
    [command handleCallbackData:data];
    
}

@end
