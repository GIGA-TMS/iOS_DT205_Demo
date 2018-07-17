//
//  GNTCommad.m
//  
//
//  Created by wilson on 2017/4/18.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import "GNTCommad.h"
#import "Header.h"
#import <netdb.h>
#import "HomePageViewController.h"
@implementation GNTCommad
{
    BOOL isHeaderExist;
}
-(NSData*)sendCommed:(char)commend{
    return [self sendCommed:commend Parameter:nil];
}

-(NSData*)sendCommed:(char)commend Parameter:(char)parameter{
    
    NSLog(@"%c",parameter);
    return [self creatCommandData:commend  Parameter:parameter];
}

-(NSData*)creatCommandData:(char)commend Parameter:(char)parameter{
    
    NSMutableData* data = [[NSMutableData alloc]init];
    const char header = (char)DEVICE_COMMAND_HEAD;
    NSLog(@"%c",header);
    [data appendBytes:&header length:1];
    
    [data appendBytes:&commend length:1];
    //NSLog(@"%c",commend);
    NSLog(@"creatCommandData parameter : %c",parameter);
    if (parameter != '\0' || parameter != NULL) {
        
        int lenght = sizeof(parameter);
        
        if (lenght > 0) {
            [data appendBytes:&parameter length:lenght];
        }
        
    }
    const char endValue = (char)DEVICE_COMMAND_END;
    [data appendBytes:&endValue length:1];
    
    NSLog(@"%@",data);
    return data;
}

-(void)handleCallbackData:(NSData*) data{
    NSUInteger len = [data length];
    const unsigned char* pcBuffer = [data bytes];
    for (int i = 0 ; i<len; i++) {
        char data = pcBuffer[i];
        if (data == (char)DEVICE_COMMAND_HEAD) {
            _callBackDataBuffer = [NSMutableData new];
            isHeaderExist = true;
        }else if(data == (char)DEVICE_COMMAND_END){
            if (_callBackDataBuffer.length > 0) {
                NSString* callBackDataString = [[NSString alloc]initWithData:_callBackDataBuffer encoding:NSUTF8StringEncoding];
                
                if ([callBackDataString containsString:@"DT205"]) {
                    NSArray* separatedRandomString = [callBackDataString componentsSeparatedByString:@","];
                    NSString* randomString = separatedRandomString[3];
                    unsigned char aBuffer[100];
                    unsigned char* bBuffer =(unsigned char*)[randomString UTF8String];
                    int j=0;
                    for (int i = 0; i<16; i=i+2) {
                        unsigned char data1=bBuffer[i];
                        unsigned char data2=bBuffer[i+1];
                        printf(" %02X%02X ", data1, data2);
                        if(data1 >='0' && data1 <='9')
                        {
                            data1-='0';
                        }
                        else if(data1 >='A' && data1<='F')
                        {
                            data1=data1-'A';
                            data1=data1+0xA;
                        }
                        if(data2 >='0' && data2 <='9')
                        {
                            data2-='0';
                        }
                        else if(data2 >='A' && data2<='F')
                        {
                            data2=data2-'A';
                            data2=data2+0xA;
                        }
                        
                        aBuffer[j]=(data1<<4) | data2;
                        j++;
                    }
                    printf("\n\n");
                    for(int i=0; i<16; i++)
                        printf("0x%02X ", aBuffer[i]);
                    aBuffer[8] = ~(aBuffer[0]) + (aBuffer[7]);
                    aBuffer[9] = ~(aBuffer[3]) ^ (aBuffer[4]);
                    aBuffer[10] = ~(aBuffer[5]) + (aBuffer[1]);
                    aBuffer[11] = ~(aBuffer[2]) ^ aBuffer[6];
                    aBuffer[12] = ~(aBuffer[8]) ^ aBuffer[9];
                    aBuffer[13] = ~(aBuffer[10]) + aBuffer[11];
                    aBuffer[14] = aBuffer[0] ^ aBuffer[1] + aBuffer[2] + aBuffer[3] + aBuffer[4] ^ aBuffer[5] + aBuffer[6] ^ aBuffer[7];
                    aBuffer[15] = aBuffer[8] + aBuffer[9] + aBuffer[10] + aBuffer[11] + aBuffer[12] + aBuffer[13] + aBuffer[14] + 0x57;
                    
                    printf("\n\n");
                    
                    //AES KEY
                    NSData* aes_Key = [[NSData alloc]initWithBytes:aBuffer length: 16];
                }
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CallbackData" object:nil];
            }
            _callBackDataBuffer = [NSMutableData new];
            isHeaderExist = false;
        }else if(isHeaderExist){
            [_callBackDataBuffer appendBytes:&data length:1];
        }
    }
}

-(NSData*)creatCommandbyData:(char)commend Parameter:(NSData*)parameter{
    
    
    NSMutableData* data = [[NSMutableData alloc]init];
    const char header = (char)DEVICE_COMMAND_HEAD;
    NSLog(@"%c",header);
    [data appendBytes:&header length:1];
    
    [data appendBytes:&commend length:1];
    if(parameter!= nil) {
        
        NSLog(@"creatCommandbyData commend : %c, parameter : %@",commend,parameter);
    }else {
        NSLog(@"creatCommandbyData commend : %c",commend);
    }
    
    if (parameter != '\0' || parameter != NULL) {
        if ([parameter length] > 0) {
            [data appendBytes:[parameter bytes] length:[parameter length]];
        }
        
    }
    const char endValue = (char)DEVICE_COMMAND_END;
    [data appendBytes:&endValue length:1];
    
    
    return data;
}
@end
