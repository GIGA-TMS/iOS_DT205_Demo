//
//  Glog.h
//  GIGATMSSDK
//
//  Created by Gianni on 2018/5/3.
//  Copyright © 2018年 Gianni. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define GLog(x, fmt, ...) if ((x)) { NSLog(@"[T:%d] %s [L:%d] " fmt, [NSThread currentThread].isMainThread, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }
//    #define GLog(x, fmt, ...) if ((x)) { NSLog(@"[T:%@] %s [L:%d] " fmt, [NSThread currentThread], __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }
#else
#define GLog(x, fmt, ...)
#endif


@interface GLog : NSObject

+(void)byNSData:(NSString*) title data:(NSData *) cmdData;
+(void)byChar:(NSString*) title char:(const char*) pBuff;
+(void)Glog:(NSData *) cmdData;


@end
