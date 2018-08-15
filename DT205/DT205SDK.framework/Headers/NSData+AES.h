//
//  NSData+AES.h
//  
//
//  Created by Gianni on 2018/2/9.
//  Copyright © 2018年 Gianni. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)
-(NSData *)AES128EncryptedDataWithKey:(NSString *)key;

-(NSData *)AES128DecryptedDataWithKey:(NSString *)key;

-(NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv;

-(NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv;
- (NSString*)encryptionType:(NSString *)originStr key:(NSString*)key;
@end
