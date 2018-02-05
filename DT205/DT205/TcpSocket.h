//
//  Socket.h
//  GigatmsWifi
//
//  Created by wilson on 2017/6/2.
//  Copyright © 2017年 wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncSocket.h>
@interface TcpSocket : NSObject<GCDAsyncSocketDelegate>
-(void) writeData:(NSData*) data;
-(void)connectToHost:(NSString*) host Port:(NSString*)port;
@end
