//
//  GNetPlusKey.h
//  GIGATMSSDK
//
//  Created by Gianni on 2018/5/3.
//  Copyright © 2018年 Gianni. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GNetPlusKey : NSObject

- (NSData*) getAESKey;
- (id)initWithRANDOM_KEY:(NSData*)bRandomKey;
- (NSData*) getClientKey:(NSString*)szMobileUuid :(NSMutableString*) szUserPIN;
@end
