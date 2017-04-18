//
//  GNTCommad.h
//  HelloMyBLE
//
//  Created by wilson on 2017/4/18.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GNTCommad : NSObject

-(NSData*)sendCommed:(char)commend;

-(NSData*)sendCommed:(char)commend Parameter:(char*)parameter;

@end
