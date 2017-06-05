//
//  GNTCommad.m
//  HelloMyBLE
//
//  Created by wilson on 2017/4/18.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import "GNTCommad.h"
#import "Header.h"
#import <netdb.h>
@implementation GNTCommad

-(NSData*)sendCommed:(char)commend{
    return [self sendCommed:commend Parameter:nil];
}

-(NSData*)sendCommed:(char)commend Parameter:(char*)parameter{
    
    return [self creatCommandData:commend  Parameter:parameter];
}

-(NSData*)creatCommandData:(char)commend Parameter:(char*)parameter{
    
    NSMutableData* data = [[NSMutableData alloc]init];
    
    const char header = (char)DEVICE_COMMAND_HEAD;
    NSLog(@"%c",header);
    [data appendBytes:&header length:1];
    
    [data appendBytes:&commend length:1];
    NSLog(@"%c",commend);
    if (parameter != nil) {
        [data appendBytes:&parameter length:1];
    }

    const char endValue = (char)DEVICE_COMMAND_END;
    [data appendBytes:&endValue length:1];
    
    return data;
}
-(void)test{
    int socketFile = socket(AF_INET,SOCK_STREAM,0);
}

@end
