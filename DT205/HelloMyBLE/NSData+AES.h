//
//  NSData+AES.h
//  HelloMyBLE
//
//  Created by wilson on 2017/7/21.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)
-(NSData *)AES128EncryptedDataWithKey:(NSString *)key;

-(NSData *)AES128DecryptedDataWithKey:(NSString *)key;

-(NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv;

-(NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv;
@end
